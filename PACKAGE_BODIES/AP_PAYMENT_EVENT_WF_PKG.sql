--------------------------------------------------------
--  DDL for Package Body AP_PAYMENT_EVENT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PAYMENT_EVENT_WF_PKG" as
/* $Header: appewfpb.pls 120.4.12010000.2 2008/12/23 12:53:53 dcshanmu ship $ */

PROCEDURE get_check_info (p_item_type          IN VARCHAR2,
                          p_item_key           IN VARCHAR2,
                          p_actid              IN NUMBER,
                          p_funmode            IN VARCHAR2,
                          p_result             OUT NOCOPY VARCHAR2) IS

 l_check_id         ap_checks_all.check_id%type;
 l_org_id           ap_checks_all.org_id%type;
 l_check_number     ap_checks_all.check_number%type;
 l_check_date       varchar2(20);
 l_currency_code    ap_checks_all.currency_code%type;
 l_payment_amount   ap_checks_all.amount%type;
 l_email_address    IBY_EXTERNAL_PAYEES_ALL.remit_advice_email%type;

 l_message_lines1    varchar2(4000):='';
 l_message_lines2    varchar2(4000):='';
 l_message_lines3    varchar2(4000):='';
 l_message_lines4    varchar2(4000):='';
 l_message_lines5    varchar2(4000):='';
 l_message_lines6    varchar2(4000):='';
 l_message_lines7    varchar2(4000):='';
 l_message_lines8    varchar2(4000):='';
 l_message_lines9    varchar2(4000):='';
 l_message_lines10   varchar2(4000):='';
 l_message_line     varchar2(200):='';

 l_role               varchar2(100);
 l_display_role_name  varchar2(100);

 CURSOR c_message_lines IS
        SELECT  '<TR><TD>'||invoice_num||
                '</TD><TD>'||fnd_date.date_to_chardate(ai.invoice_date)||
                '</TD><TD ALIGN="RIGHT">'||to_char(aip.discount_taken)||
                '</TD><TD ALIGN="RIGHT">'||to_char(aip.amount)||'</TD></TR>'
        FROM    ap_invoice_payments aip, ap_invoices ai
        WHERE   aip.check_id = l_check_id
        AND     ai.invoice_id = aip.invoice_id
        ORDER BY invoice_num;

 BEGIN

     /* Get the check_id stored in the attribute check_id */

     l_check_id := wf_engine.getitemattrnumber(p_item_type,
                                               p_item_key,
                                               'CHECK_ID');

      /* Get the org_id stored in the attribute check_id */

     l_org_id   := wf_engine.getitemattrnumber(p_item_type,
                                               p_item_key,
                                               'ORG_ID');

     /* Set the Org ID context */

      if l_org_id is not null
      then

         fnd_client_info.set_org_context(l_org_id);

      end if;

     /* Get Basic Check Info */

     SELECT check_number,
            fnd_date.date_to_chardate(check_date),
            currency_code,
            amount
     INTO   l_check_number,
            l_check_date,
            l_currency_code,
            l_payment_amount
     FROM   ap_checks
     WHERE  check_id = l_check_id;

    OPEN c_message_lines;

    LOOP

       FETCH c_message_lines INTO l_message_line;
       EXIT WHEN c_message_lines%NOTFOUND;

       IF    length(l_message_lines1||l_message_line) <= 4000 THEN
          l_message_lines1 := l_message_lines1 || l_message_line;
       ELSIF length(l_message_lines2||l_message_line) <= 4000 THEN
          l_message_lines2 := l_message_lines2 || l_message_line;
       ELSIF length(l_message_lines3||l_message_line) <= 4000 THEN
          l_message_lines3 := l_message_lines3 || l_message_line;
       ELSIF length(l_message_lines4||l_message_line) <= 4000 THEN
          l_message_lines4 := l_message_lines4 || l_message_line;
       ELSIF length(l_message_lines5||l_message_line) <= 4000 THEN
          l_message_lines5 := l_message_lines5 || l_message_line;
       ELSIF length(l_message_lines6||l_message_line) <= 4000 THEN
          l_message_lines6 := l_message_lines6 || l_message_line;
       ELSIF length(l_message_lines7||l_message_line) <= 4000 THEN
          l_message_lines7 := l_message_lines7 || l_message_line;
       ELSIF length(l_message_lines8||l_message_line) <= 4000 THEN
          l_message_lines8 := l_message_lines8 || l_message_line;
       ELSIF length(l_message_lines9||l_message_line) <= 4000 THEN
          l_message_lines9 := l_message_lines9 || l_message_line;
       ELSIF length(l_message_lines10||l_message_line) <= 4000 THEN
          l_message_lines10 := l_message_lines10 || l_message_line;
       END IF;

    END LOOP;

    CLOSE c_message_lines;

    /* Get Supplier's Remittance Email Address */
    get_remit_email_address(l_check_id,l_email_address);

    l_role := null;
    l_display_role_name := null;

    -- BUG 4281586 changed from MAILHTML to MAILHTM2
    WF_DIRECTORY.createAdhocRole(role_name => l_role,
                                 role_display_name => l_display_role_name,
                                 email_address => l_email_address,
                                 notification_preference => 'MAILHTM2');


    /* Set Check Number to WorkFlow Attribute */
    wf_engine.setitemattrnumber(P_item_type,
                                p_item_key,
                               'CHECK_NUMBER',
                                l_check_number);

    /* Set Check Date to the WorkFlow Attribute */
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                             'CHECK_DATE',
                              l_check_date);

    /* Set Payment Currency Code to Workflow Attribute */
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                             'PAYMENT_CURRENCY',
                              l_currency_code);

    /* Set Check Amount to the Workflow Attribute */
    wf_engine.setitemattrnumber(p_item_type,
                                p_item_key,
                               'CHECK_AMOUNT',
                                l_payment_amount);

    /* Set Email Address to Workflow Adhoc Role */
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'EMAIL_ADDRESS',
                              l_role);

    /* Set Invoices List Information to the Invoices List Attribute */
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST1',
                              l_message_lines1);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST2',
                              l_message_lines2);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST3',
                              l_message_lines3);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST4',
                              l_message_lines4);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST5',
                              l_message_lines5);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST6',
                              l_message_lines6);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST7',
                              l_message_lines7);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST8',
                              l_message_lines8);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST9',
                              l_message_lines9);
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'INVOICES_LIST10',
                              l_message_lines10);

 END get_check_info;

 -------------------------------------------------------------------------------
 ------- Procedure get_remit_email_address returns the Remittance Email Address
 ------- of the Supplier. This procedure is called by get_check_info and rule_function
 ------- procedures
 -------------------------------------------------------------------------------

  PROCEDURE get_remit_email_address (p_check_id      in  NUMBER,
                                     p_email_address out NOCOPY VARCHAR2) is

  l_vendor_id         po_vendor_sites_all.vendor_id%type;
  l_vendor_site_id    po_vendor_sites_all.vendor_site_id%type;

  BEGIN

    SELECT vendor_id,
           vendor_site_id
    INTO   l_vendor_id,
           l_vendor_site_id
    FROM   ap_checks
    WHERE  check_id = p_check_id;

   --bug6119080, changed the query to fetch the email address from the
   --correct table.
    SELECT remit_advice_email
    INTO   p_email_address
    FROM   IBY_EXTERNAL_PAYEES_ALL
    WHERE  supplier_site_id = l_vendor_site_id;

  END get_remit_email_address;

 -------------------------------------------------------------------------------
 ------- Procedure get_remit_email_address returns the Remittance Email Address
 ------- of the Supplier. This procedure is called by get_check_info and rule_function
 ------- procedures
 -------------------------------------------------------------------------------------------

  PROCEDURE get_check_status  (p_check_id     in NUMBER,
                               p_check_status out NOCOPY VARCHAR2) is


  BEGIN

    SELECT status_lookup_code
    INTO   p_check_status
    FROM   ap_checks
    WHERE  check_id = p_check_id;

  END get_check_status;

 ------ Procedure rule_function is called by the Subscription program. Rule Function determines
 ------ whether WorkFlow Program should be called.
 ------ Rule Defined is that to call the Workflow program only if the Remittance Email Address
 ------ is available for the Supplier.
 -------------------------------------------------------------------------------------------

  FUNCTION rule_function (p_subscription in RAW,
                          p_event        in out NOCOPY WF_EVENT_T) return varchar2 is


 l_rule                  VARCHAR2(20);
 l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
 l_parameter_t           wf_parameter_t:= wf_parameter_t(null, null);
 i_parameter_name        l_parameter_t.name%type;
 i_parameter_value       l_parameter_t.value%type;
 i                       pls_integer;

 l_check_id              l_parameter_t.value%type;
 l_org_id                l_parameter_t.value%type;
 l_email_address         IBY_EXTERNAL_PAYEES_ALL.remit_advice_email%type;
 l_check_status          ap_checks_all.status_lookup_code%type;

 BEGIN

    l_parameter_list := p_event.getParameterList();
        if l_parameter_list is not null
        then
                i := l_parameter_list.FIRST;
                while ( i <= l_parameter_list.LAST )
                loop
                        i_parameter_name := null;
                        i_parameter_value := null;

                        i_parameter_name := l_parameter_list(i).getName();
                        i_parameter_value := l_parameter_list(i).getValue();

                        if i_parameter_name is not null
                        then
                                if    i_parameter_name = 'CHECK_ID'
                                then
                                        l_check_id := i_parameter_value;
                                elsif i_parameter_name = 'ORG_ID'
                                then
                                        l_org_id   := i_parameter_value;
                                end if;
                        end if;
                        i := l_parameter_list.NEXT(i);
                end loop;

          end if;


    /* Set the Org_id Context */

      if l_org_id is not null
      then

        --bug6119080, commented the existing code and added the new the code
        --to properly set the org context.

	-- fnd_client_info.set_org_context(l_org_id);
        mo_global.set_policy_context('S',l_org_id);

      end if;


    /* Convert check_id into number as function get_value returns
       it as a varchar2 */

       get_remit_email_address(to_number(l_check_id),l_email_address);

    /* Get the status of the Check */

       get_check_status(to_number(l_check_id),l_check_status);


    /* if email address is missing, then do not execute WF program */

    if l_email_address is not null
    then

      /* if check is voided, then do not execute WF program */

      if l_check_status <> 'VOIDED'
      then

         l_rule :=  wf_rule.default_rule(p_subscription,p_event);

      end if;

    end if;

   return ('SUCCESS');

 END rule_function;

END AP_PAYMENT_EVENT_WF_PKG;

/
