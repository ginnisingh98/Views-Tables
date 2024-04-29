--------------------------------------------------------
--  DDL for Package Body CSC_UWQ_FORM_ROUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_UWQ_FORM_ROUTE" AS
/* $Header: cscpuwqb.pls 120.12.12010000.2 2009/12/24 16:48:20 spamujul ship $ */

   --package private variables
   pp_media_table           SYSTEM.IEU_UWQ_MEDIA_DATA_NST;
   l_country_code           VARCHAR2(4);
   l_area_code              VARCHAR2(4);
   l_phone_num              VARCHAR2(10);
   l_phone_ext              VARCHAR2(10);

FUNCTION GET_MEDIA_VALUE ( p_media_name   IN  VARCHAR2)

--FUNCTION: get_media_value
--USAGE: internal, private function used by CSC_UWQ_Form_Obj
--Description: get the data value for the paramater named passed in
--the media table placed into the package variable pp_media_table

RETURN VARCHAR2 IS

BEGIN

   FOR i in 1..pp_media_table.COUNT LOOP
      IF pp_media_table(i).param_name = p_media_name THEN
         RETURN pp_media_table(i).param_value;
      END IF;
   END LOOP;

   return null;

END GET_MEDIA_VALUE;

PROCEDURE CSC_UWQ_FORM_OBJ ( p_ieu_media_data IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
                             p_action_type   OUT NOCOPY NUMBER,
                             p_action_name   OUT NOCOPY VARCHAR2,
                             p_action_param  OUT NOCOPY VARCHAR2) IS

--Procedure   : CSC_UWQ_Form_Obj
--Usage       : Used by UWQ to call Contact Center Form
--Description : This procedure takes the table of objects containing
--              the meta data as input and gives the following as output:
--              1. Action Type -  Method to be used to call the contact center form
--              like APP_NAVIGATE.EXECUTE or FND_FUNCTION.EXECUTE etc.
--              2. Action Name - Name of the function to call the contact center form.
--              3. Action Param - Parameters to be passed to the contact center form.
--              Parameters  : p_ieu_media_data IN SYSTEM.IEW_UWQ_MEDIA_DATA_NST Required
--              p_action_type OUT NUMBER
--              p_action_name OUT VARCHAR2
--              p_action_param OUT VARCHAR2

   l_name                             VARCHAR2(500);
   l_value                            VARCHAR2(1996);
   l_type                             VARCHAR2(500);

   --Variables used only for transfer/conference values
   l_xfer_action_id                        NUMBER;
   l_xfer_interaction_id                   NUMBER;
   l_xfer_employee_id				Varchar2(30); -- Added by spamujul for 8911024
   l_xfer_service_key_name                 VARCHAR2(40);
   l_xfer_service_key_value                VARCHAR2(240);
   l_xfer_call_reason                      VARCHAR2(40);
   l_xfer_cust_party_id                    NUMBER;
   l_xfer_rel_party_id                     NUMBER;
   l_xfer_per_party_id                     NUMBER;
   l_xfer_cust_phone_id                    NUMBER;
   l_xfer_cust_email_id                    NUMBER;
   l_xfer_rel_phone_id                     NUMBER;
   l_xfer_rel_email_id                     NUMBER;
   l_xfer_cust_account_id                  NUMBER;
   l_trans_conf_flag                       VARCHAR2(1) := 'N';
   l_party_id                              NUMBER;

   --Variables used only for inbound call values
   l_customer_id                      NUMBER;
   l_cust_account_id                  NUMBER;
   l_acct_last_update_date            DATE;
   l_email_cust_id                    NUMBER;
   l_contract_num                     VARCHAR2(240);
   l_invoice_num                      VARCHAR2(240);
   l_order_num                        VARCHAR2(240);
   l_rma_num                          VARCHAR2(240);
   l_serial_num                       VARCHAR2(240);
   l_service_request_num              VARCHAR2(240);
   l_instance_name                    VARCHAR2(240);
   l_tag_num                          VARCHAR2(240);
   l_system_name                      VARCHAR2(240);
   l_call_reason                      VARCHAR2(40);
   l_ccode                            VARCHAR(10);
   l_acode                            VARCHAR(10);
   l_phone_number                     VARCHAR(40);
   l_complete_phone_num               VARCHAR(60);
   l_phone_passed_flag                VARCHAR2(1) := 'N';
   l_phone_id                         NUMBER;
   l_uwq_multi_record_match           VARCHAR2(2000);
   l_rphone                           VARCHAR2(1996);
   n_use_exact_ani                    VARCHAR2(200);
   l_ssn                              VARCHAR2(240);

   --Variables that may be used for transfer/conference or inbound call
   l_block_mode_flag                  VARCHAR2(1) := 'F';
   l_cont_mode_flag                   VARCHAR2(1) := 'T';
   l_open_new_CC                      VARCHAR2(1) := 'N';

   --Created to pass a null party id in case of email where the party id is null
   l_dummy_customer_id                NUMBER;

   --R12 new variables
    l_match                           varchar2(1):='0';
    l_processed_flag                  varchar2(1):='N';
    l_fromEBC                         varchar2(1):='N';
    l_whichIVR                        varchar2(20);
    l_skey_cust_phone_id              varchar2(100);
    l_skey_account_id                 varchar2(100);
    l_skey_rel_party_id               varchar2(100);
    l_skey_rel_phone_id               varchar2(100);
    l_skey_per_party_id               varchar2(100);
    l_skey_rel_email_id               varchar2(100);
    l_skey_cust_email_id              varchar2(100);
    l_uwq_multi_record_match2          varchar2(2000);
    l_uwq_reverse_ani                 varchar2(200);
    l_uwq_phone_id                    number;
    l_uwq_complete_phone_num          varchar2(60);
--aaa
    l_uwq_cust_acct_id                number;
    l_uwq_acct_last_upd_date          date;
    l_uwq_stripped_rev_ani2           varchar2(200);

    l_employee_id                     varchar2(200);
    l_instance_num                   VARCHAR2(240);

    --bug 5640146
    l_service_key_id                  number;
    l_uwq_skey_org_id                 number;
    --end of bug 5640146


BEGIN

   l_customer_id := null;

   pp_media_table := p_ieu_media_data;

   p_action_name := 'CSCCCCRC';
   p_action_param := 'called_from="UWQ"';

   --Loop through the array of data objects to retrieve the parameters that are passed
   FOR i IN 1..p_ieu_media_data.COUNT LOOP
      l_name  := p_ieu_media_data(i).param_name;
      l_value := p_ieu_media_data(i).param_value;
      l_type  := p_ieu_media_data(i).param_type;

      --Check the names of the parameters and assign their values to build the string to be passed to CC
      IF l_name = 'ACTION_ID' THEN
         if (l_value is not null) then
            l_trans_conf_flag := 'Y';
         end if;
         l_xfer_action_id := l_value;
      ELSIF l_name = 'INTERACTION_ID' THEN
         l_xfer_interaction_id := l_value;
      ELSIF l_name = 'SERVICE_KEY_NAME' THEN
         l_xfer_service_key_name := l_value;
      ELSIF l_name = 'SERVICE_KEY_VALUE' THEN
         l_xfer_service_key_value := l_value;
      ELSIF l_name = 'CALL_REASON' THEN
         l_xfer_call_reason := l_value;
	  -- Begin fix by spamujul for 8911024
      ELSIF l_name = 'EMPLOYEE_ID' THEN
         l_xfer_employee_id	:= l_value;
     -- End fix by spamujul for 8911024
      ELSIF l_name = 'CUST_PARTY_ID' THEN
         l_xfer_cust_party_id := l_value;
      ELSIF l_name = 'REL_PARTY_ID' THEN
         l_xfer_rel_party_id := l_value;
      ELSIF l_name = 'PER_PARTY_ID' THEN
         l_xfer_per_party_id := l_value;
      ELSIF l_name = 'CUST_PHONE_ID' THEN
         l_xfer_cust_phone_id := l_value;
      ELSIF l_name = 'CUST_EMAIL_ID' THEN
         l_xfer_cust_email_id := l_value;
      ELSIF l_name = 'REL_PHONE_ID' THEN
         l_xfer_rel_phone_id := l_value;
      ELSIF l_name = 'REL_EMAIL_ID' THEN
         l_xfer_rel_email_id := l_value;
      ELSIF l_name = 'CUST_ACCOUNT_ID' THEN
         l_xfer_cust_account_id := l_value;
      ELSIF l_name = 'PARTY_ID' THEN
         --l_party_id := l_value;
         l_customer_id := l_value;
      ELSIF l_name = 'CustomerID' THEN
         l_customer_id := l_value;
      ELSIF l_name = 'CustomerNum' THEN
         p_action_param := p_action_param||'uwq_object_num="'||l_value||'"';
      ELSIF l_name = 'ContactNum' THEN
         p_action_param := p_action_param||'uwq_subject_num="'||l_value||'"';
      ELSIF l_name = 'AccountCode' THEN
         p_action_param := p_action_param||'uwq_account_number="'||l_value||'"';
      ELSIF l_name = 'ContractNum' THEN
         l_contract_num := l_value;
      ELSIF l_name = 'InvoiceNum' THEN
         l_invoice_num := l_value;
      ELSIF l_name = 'OrderNum' THEN
         l_order_num := l_value;
      ELSIF l_name = 'SSN' THEN
         l_ssn := l_value;
      ELSIF l_name = 'SocialSecurityNumber' THEN
         l_ssn := l_value;
      ELSIF l_name = 'RMANum' THEN
         l_rma_num := l_value;
      ELSIF l_name = 'SerialNum' THEN
         l_serial_num  := l_value;
      ELSIF l_name = 'ServiceRequestNum' THEN
         l_service_request_num := l_value;
      ELSIF l_name = 'InstanceName' THEN
         l_instance_name := l_value;
      ELSIF l_name = 'InstanceNum' THEN
         l_instance_num := l_value;
      ELSIF l_name = 'TagNumber' THEN
         l_tag_num := l_value;
      ELSIF l_name = 'SystemName' THEN
         l_system_name := l_value;
      ELSIF l_name = 'CountryCode' THEN
         l_phone_passed_flag := 'Y';
         l_ccode := l_value;
      ELSIF l_name = 'AreaCode' THEN
         l_phone_passed_flag := 'Y';
         l_acode := l_value;
      ELSIF l_name = 'PhoneNumber' THEN
         l_phone_passed_flag := 'Y';
         l_phone_number := l_value;
      ELSIF l_name = 'occtScreenPopAction' THEN
         l_call_reason := l_value;
      ELSIF l_name = 'UWQ_BLOCK_MODE' THEN
         l_block_mode_flag := l_value;
      ELSIF l_name = 'UWQ_CONTINUOUS_MODE' THEN
         l_cont_mode_flag := l_value;
      ELSIF l_name = 'occtANI' THEN
         p_action_param := p_action_param||'uwq_ani="'||l_value||'"';
      ELSIF l_name = 'occtMediaItemID' THEN
         p_action_param := p_action_param||'uwq_media_item_id="'||l_value||'"';
      ELSIF l_name = 'occtEventName' THEN
         p_action_param := p_action_param||'uwq_event="'||l_value||'"';
      ELSIF l_name = 'occtAgentID' THEN
         p_action_param := p_action_param||'uwq_agent="'||l_value||'"';
      ELSIF l_name = 'occtDNIS' THEN
         p_action_param := p_action_param||'uwq_dnis="'||l_value||'"';
      ELSIF l_name = 'workItemID' THEN
         p_action_param := p_action_param||'uwq_work_item_id="'||l_value||'"';
      ELSIF l_name = 'occtMediaType' THEN
         p_action_param := p_action_param||'uwq_media_type="'||l_value||'"';
      ELSIF l_name = 'occtCallID' THEN
         p_action_param := p_action_param||'uwq_call_id="'||l_value||'"';
      ELSIF l_name = 'oiemSenderName' and l_value is not null THEN
         l_email_cust_id := csc_routing_utl.Get_Customer_from_Email(l_value);
      ELSIF l_name = 'CustomerProductID' THEN
         p_action_param := p_action_param||'uwq_cust_prod_id="'||l_value||'"';
      ELSIF l_name = 'InventoryItemID' THEN
         p_action_param := p_action_param||'uwq_inventory_id="'||l_value||'"';
      ELSIF l_name = 'employeeID' THEN
         l_employee_id := l_value;
         --p_action_param := p_action_param||'uwq_employee_id="'||l_value||'"';
      ELSIF l_name = 'LotNum' THEN
         p_action_param := p_action_param||'uwq_lot_num="'||l_value||'"';
      ELSIF l_name = 'PurchaseOrderNum' THEN
         p_action_param := p_action_param||'uwq_purchase_order_num="'||l_value||'"';
      ELSIF l_name = 'QuoteNum' THEN
         p_action_param := p_action_param||'uwq_quote_num="'||l_value||'"';
      --
      --New Parameters for R12
      --
      ELSIF l_name = 'WhichIVR' THEN
         l_whichIVR := l_value;
      ELSIF l_name = 'MatchFlag' THEN
         l_match := l_value;
      ELSIF l_name = 'FromEBC' THEN
         l_fromEBC := l_value;
      ELSIF l_name = 'SKEY_cust_phone_id' THEN
         l_skey_cust_phone_id := l_value;
      ELSIF l_name = 'SKEY_account_id' THEN
         l_skey_account_id := l_value;
      ELSIF l_name = 'SKEY_rel_party_id' THEN
         l_skey_rel_party_id := l_value;
      ELSIF l_name = 'SKEY_rel_phone_id' THEN
         l_skey_rel_phone_id := l_value;
      ELSIF l_name = 'SKEY_per_party_id' THEN
         l_skey_per_party_id := l_value;
      ELSIF l_name = 'SKEY_rel_email_id' THEN
         l_skey_rel_email_id := l_value;
      ELSIF l_name = 'SKEY_cust_email_id' THEN
         l_skey_cust_email_id := l_value;
      ELSIF l_name = 'ProcessedFlag' THEN
         l_processed_flag := l_value;
      ELSIF l_name = 'uwq_phone_id' THEN
         l_uwq_phone_id := l_value;
      ELSIF l_name = 'uwq_reverse_ani' THEN
         l_uwq_reverse_ani := l_value;
      ELSIF l_name = 'uwq_multi_record_match' THEN
         l_uwq_multi_record_match2 := l_value;
      ELSIF l_name = 'uwq_stripped_reverse_ani' THEN
         l_uwq_stripped_rev_ani2 := l_value;
      ELSIF l_name = 'service_key_id' THEN
	 --bug 5640146
      --Needs to look for service_key_id for ordernum,system,instance name and intance number
         l_service_key_id := l_value;
      ELSIF l_name = 'uwq_skey_org_id' THEN
      --Needs to look for uwq_skey_org_id for ordernum,rma and invoice number
         l_uwq_skey_org_id := l_value;
      END IF;
	 --end of bug 5640146
   END LOOP;

   --Check if a new instance of CC needs to be opened or existing instance has to be refreshed
   --If call is not from the queue (unsolicited call) then open new instance of CC
   IF (l_block_mode_flag = 'T' and l_cont_mode_flag ='T') OR
      (l_block_mode_flag = 'T' and l_cont_mode_flag ='F') OR
      (l_block_mode_flag = 'F' and l_cont_mode_flag ='F') THEN
      l_open_new_CC := 'Y';
   --Else refresh existing instance of CC
   ELSIF (l_block_mode_flag = 'F' and l_cont_mode_flag ='T') THEN
      l_open_new_CC := 'N';
   END IF;

   --IF new instance of CC has to be opened, pass fnd_function.execute in p_action_type
   IF (l_open_new_CC = 'Y') THEN
      p_action_type := 2;
   --Else if existing instance of CC has to be refreshed, pass app_navigate in p_action_type
   ELSIF (l_open_new_CC = 'N') THEN
      p_action_type := 1;
   END IF;

   --At this point, if it is a transfer or conference call, then all the data required to
   --populate contact center form is available, hence return to calling procedure.
   --But, if it is a transfer or conference call, and if no cust_party_id is passed
   --and no service key value is passed and no party id is passed, then it implies that the
   --transfer or conference was made without selecting a record.
   --In that case, further code to determine party id from inbound call data must be executed.
   IF (l_trans_conf_flag = 'Y') THEN
      --This IF condition is added to fix bug 3773311. It is specific to xfr between
      --telesales and cc.
      IF (l_xfer_cust_party_id is not null) AND
         (l_xfer_rel_party_id is not null) AND
         (l_xfer_cust_party_id = l_xfer_rel_party_id) AND
         (l_xfer_cust_party_id <> nvl(l_xfer_per_party_id,-1)) THEN

         --since this is a xfr call from ebc, all search keys would needed to be initialized
         --to avoid any confusion.
         l_service_request_num := null;
         l_instance_name := null;
         l_instance_num := null;
         l_serial_num := null;
         l_tag_num := null;
         l_system_name := null;
         l_rma_num := null;
         l_order_num := null;
         l_ssn := null;
         l_contract_num := null;
         l_invoice_num := null;
         --make sure employee_id is null because ebc does not pass this
         l_employee_id := null;
         p_action_param := p_action_param||'uwq_service_key_name=""';
         p_action_param := p_action_param||'uwq_service_key_value=""';
      ELSE
	 p_action_param := p_action_param||'uwq_employee_id="'||l_xfer_employee_id||'"'; -- Added by spamujul for Bug 8911024
         p_action_param := p_action_param||'uwq_action_id="'||l_xfer_action_id||'"';
         p_action_param := p_action_param||'uwq_interaction_id="'||l_xfer_interaction_id||'"';
         p_action_param := p_action_param||'uwq_cust_party_id="'||l_xfer_cust_party_id||'"';
         p_action_param := p_action_param||'uwq_rel_party_id="'||l_xfer_rel_party_id||'"';
         p_action_param := p_action_param||'uwq_per_party_id="'||l_xfer_per_party_id||'"';
         p_action_param := p_action_param||'uwq_cust_phone_id="'||l_xfer_cust_phone_id||'"';
         p_action_param := p_action_param||'uwq_cust_email_id="'||l_xfer_cust_email_id||'"';
         p_action_param := p_action_param||'uwq_rel_phone_id="'||l_xfer_rel_phone_id||'"';
         p_action_param := p_action_param||'uwq_rel_email_id="'||l_xfer_rel_email_id||'"';

         if (l_xfer_cust_account_id is not null) then
            p_action_param := p_action_param||'uwq_cust_account_id="'||l_xfer_cust_account_id||'"';
         end if;

         if (l_xfer_service_key_value is not null) then
            p_action_param := p_action_param||'uwq_service_key_value="'||l_xfer_service_key_value||'"';
         end if;

         if (l_xfer_service_key_name is not null) then
            p_action_param := p_action_param||'uwq_service_key_name="'||l_xfer_service_key_name||'"';
         end if;

         if (l_xfer_call_reason is not null) then
            p_action_param := p_action_param||'uwq_call_reason="'||l_xfer_call_reason||'"';
         end if;

         /*if (l_party_id is not null) then
            p_action_param := p_action_param||'uwq_party_id="'||l_party_id||'"';
         end if;*/

         IF (l_xfer_cust_party_id is not null) OR
            (l_xfer_service_key_name is not null and l_xfer_service_key_value is not null) THEN

            IF (l_service_key_id is not null) THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            RETURN;
         END IF;
      END IF;
   END IF;

   --hbchung
   --
   --New R12 logic
   --
   IF l_processed_flag = 'Y' THEN
      p_action_param := p_action_param||'uwq_lookup_flag="'||l_processed_flag||'"';
      p_action_param := p_action_param||'uwq_which_ivr="'||l_whichIVR||'"';
      p_action_param := p_action_param||'uwq_match_flag="'||l_match||'"';

   --Need to set call reason
   IF l_call_reason is not null then
      p_action_param := p_action_param||'uwq_call_reason="'||l_call_reason||'"';
   END IF;

      IF l_whichIVR = 'PartyID' THEN
         p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
         RETURN;
      ELSIF l_whichIVR = 'ANI' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'"';
            p_action_param := p_action_param||'uwq_phone_id="'||l_uwq_phone_id ||'"';
         ELSIF (l_match = 'M') THEN
            p_action_param := p_action_param||'uwq_stripped_reverse_ani="'|| l_uwq_stripped_rev_ani2 ||'"';
         END IF;

         p_action_param := p_action_param||'uwq_multi_record_match="'||l_uwq_multi_record_match2||'"';
         p_action_param := p_action_param||'uwq_reverse_ani="'||l_uwq_reverse_ani ||'"';
         RETURN;
      ELSIF l_whichIVR = 'AccountCode' THEN
         p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'"';
         p_action_param := p_action_param||'uwq_cust_account_id="'||l_uwq_cust_acct_id ||'"';
         p_action_param := p_action_param||'uwq_last_update_date="'||l_uwq_acct_last_upd_date ||'"';
         RETURN;
      ELSIF l_whichIVR = 'SR' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_cust_phone_id="'||l_skey_cust_phone_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';
            p_action_param := p_action_param||'uwq_skey_rel_party_id="'||l_skey_rel_party_id||'"';
            p_action_param := p_action_param||'uwq_skey_rel_phone_id="'||l_skey_rel_phone_id||'"';
            p_action_param := p_action_param||'uwq_skey_per_party_id="'||l_skey_per_party_id||'"';
            p_action_param := p_action_param||'uwq_skey_rel_email_id="'||l_skey_rel_email_id||'"';
            p_action_param := p_action_param||'uwq_skey_cust_email_id="'||l_skey_cust_email_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
		  END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
		     p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
		  END IF;
            --end of bug 5640146

            --for case where SR belongs to employee
            if l_employee_id is not null THEN
               p_action_param := p_action_param||'uwq_employee_id="'||l_employee_id||'"';
            end if;
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'SERVICE_REQUEST_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_service_request_num||'"';
         RETURN;
      --New HelpDesk logic to handle Employee Id
      ELSIF l_whichIVR = 'Employee' THEN
         p_action_param := p_action_param||'uwq_employee_id="'||l_employee_id||'"';
         RETURN;
      ELSIF l_whichIVR = 'InstanceName' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'INSTANCE_NAME'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_instance_name||'"';
         RETURN;
      ELSIF l_whichIVR = 'InstanceNum' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'INSTANCE_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_instance_num||'"';
         RETURN;
      ELSIF l_whichIVR = 'SerialNum' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'SERIAL_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_serial_num||'"';
         RETURN;
      ELSIF l_whichIVR = 'TagNum' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'EXTERNAL_REFERENCE'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_tag_num||'"';
         RETURN;
      ELSIF l_whichIVR = 'SystemName' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'SYSTEM_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_system_name||'"';
         RETURN;
      ELSIF l_whichIVR = 'RMANum' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'RMA_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_rma_num||'"';
         RETURN;
      ELSIF l_whichIVR = 'OrderNum' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'ORDER_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_order_num||'"';
         RETURN;
      ELSIF l_whichIVR = 'SSN' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'SSN'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_ssn||'"';
         RETURN;
      ELSIF l_whichIVR = 'ContractNum' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'CONTRACT_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_contract_num||'"';
         RETURN;
      ELSIF l_whichIVR = 'InvoiceNum' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
            p_action_param := p_action_param||'uwq_skey_account_id="'||l_skey_account_id||'"';

            --bug 5640146
            IF l_service_key_id IS NOT NULL THEN
               p_action_param := p_action_param||'service_key_id="'||l_service_key_id||'"';
	       END IF;

            IF l_uwq_skey_org_id IS NOT NULL THEN
	          p_action_param := p_action_param||'uwq_skey_org_id="'||l_uwq_skey_org_id||'"';
	       END IF;
            --end of bug 5640146
         END IF;

         p_action_param := p_action_param||'uwq_service_key_name="'||'INVOICE_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_invoice_num||'"';
         RETURN;
      ELSIF l_whichIVR = 'CompletePhone' THEN
         IF (l_match = '1') THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'"';
            p_action_param := p_action_param||'uwq_phone_id="'||l_uwq_phone_id ||'"';
         ELSIF (l_match = 'M') THEN
            p_action_param := p_action_param||'uwq_stripped_reverse_ani="'|| l_uwq_stripped_rev_ani2 ||'"';
         END IF;

         p_action_param := p_action_param||'uwq_complete_phone_num="'||l_uwq_complete_phone_num ||'"';
         p_action_param := p_action_param||'uwq_reverse_ani="'||l_uwq_reverse_ani ||'"';
         p_action_param := p_action_param||'uwq_multi_record_match="'||l_uwq_multi_record_match2||'"';
         RETURN;
      END IF;
        ------------------------------------
   ELSE --Did not go thru CC customer lookup
        -----------------------------------
   --At this point, it is either an inbound call or a transfer/conference call for which
   --insufficient data has been passed.  In both cases, need to process inbound call data.
   --First preference is given to user hook.
   IF JTF_USR_HKS.OK_TO_EXECUTE('CSC_UWQ_FORM_ROUTE', 'CSC_UWQ_FORM_OBJ', 'B', 'C') THEN
      l_customer_id := NULL;
      l_cust_account_id := NULL;
      l_phone_id := NULL;

      CSC_UWQ_FORM_ROUTE_CUHK.CSC_UWQ_FORM_OBJ_PRE(p_ieu_media_data  => p_ieu_media_data,
                                                   x_party_id        => l_customer_id,
                                                   x_cust_account_id => l_cust_account_id,
                                                   x_phone_id        => l_phone_id);

      p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
      If l_cust_account_id is not null Then
         p_action_param := p_action_param||'uwq_cust_account_id="'||l_cust_account_id ||'"';
      End If;
      If l_phone_id is not null Then
         p_action_param := p_action_param||'uwq_phone_id="'||l_phone_id ||'"';
      End If;
      RETURN;

   --If user hook is not executed, then process inbound call data
   ELSE

      if l_call_reason is not null then
         p_action_param := p_action_param||'uwq_call_reason="'||l_call_reason||'"';
      end if;

      --Set service key name and value based on the hierarchy specified in SRD
      if l_customer_id is not null then
         p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
         --this fix is for user who uses default or custom lookup, even when l_customer_id is not null
         --it will still check for service key value pairs
         if (l_service_request_num is null) AND
            (l_instance_name is null) AND
            (l_instance_num is null) AND
            (l_serial_num is null) AND
            (l_tag_num is null) AND
            (l_system_name is null) AND
            (l_rma_num is null) AND
            (l_order_num is null) AND
            (l_ssn is null) AND
            (l_contract_num is null) AND
            (l_invoice_num is null) THEN
            RETURN;
         end if;
      end if;

      if l_service_request_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'SERVICE_REQUEST_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_service_request_num||'"';
         RETURN;
      elsif l_employee_id is not null then
         p_action_param := p_action_param||'uwq_employee_id="'||l_employee_id||'"';
         RETURN;
      elsif l_instance_name is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'INSTANCE_NAME'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_instance_name||'"';
         RETURN;
      elsif l_instance_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'INSTANCE_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_instance_num||'"';
         RETURN;
      elsif l_serial_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'SERIAL_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_serial_num||'"';
         RETURN;
      elsif l_tag_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'EXTERNAL_REFERENCE'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_tag_num||'"';
         RETURN;
      elsif l_system_name is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'SYSTEM_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_system_name||'"';
         RETURN;
      elsif l_rma_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'RMA_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_rma_num||'"';
         RETURN;
      elsif l_order_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'ORDER_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_order_num||'"';
         RETURN;
      elsif l_ssn is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'SSN'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_ssn||'"';
         RETURN;
      elsif l_contract_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'CONTRACT_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_contract_num||'"';
         RETURN;
      elsif l_invoice_num is not null then
         p_action_param := p_action_param||'uwq_service_key_name="'||'INVOICE_NUMBER'||'"';
         p_action_param := p_action_param||'uwq_service_key_value="'||l_invoice_num||'"';
         RETURN;
      end if;

      --If the control comes to this part of the code, then that means the party_id may or may not
      --be available to be passed to CC.  Therefore, need to go through the extra logic to derive
      --the party_id to be passed to CC.
      --Process each of the uwq supplied IVR params to try and resolve the party_id
      --Quit when an id is located. The order processed is significant as it attempts
      --to process the most likely IVR values to yield a party id

      if l_email_cust_id is not null then
         p_action_param := p_action_param||'uwq_party_id="'||l_email_cust_id||'"';
         RETURN;
      end if;

      l_value := get_media_value('CustomerNum');
      IF l_value IS NOT NULL THEN
         l_customer_id := null;
         l_customer_id := CSC_ROUTING_UTL.Get_Customer_From_CustomerNum(p_party_number => l_value);
         IF l_customer_id IS NOT NULL THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'"';
            RETURN;
         END IF;
      END IF;

      --Preserve account number and get account id and last update date
      --so that it does not have to be re-queried on the client side
      l_value := get_media_value('AccountCode');
      IF l_value IS NOT NULL THEN
         l_customer_id := null;
         CSC_ROUTING_UTL.Get_Cust_Acct_From_Account_Num( p_cust_acct_number  => l_value,
                                                         x_party_id          => l_customer_id,
                                                         x_cust_account_id   => l_cust_account_id,
                                                         x_last_update_date  => l_acct_last_update_date);
         IF l_customer_id IS NOT NULL THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'"';
            p_action_param := p_action_param||'uwq_cust_account_id="'||l_cust_account_id ||'"';
            p_action_param := p_action_param||'uwq_last_update_date="'||l_acct_last_update_date ||'"';
            RETURN;
         END IF;
      END IF;

      --Check for phone number
      if l_phone_passed_flag = 'Y' then
         l_complete_phone_num := l_ccode || l_acode || l_phone_number;
         IF l_complete_phone_num IS NOT NULL THEN
            l_customer_id := NULL;
            l_rphone := HZ_PHONE_NUMBER_PKG.transpose(l_complete_phone_num);
            l_customer_id := CSC_ROUTING_UTL.get_customer_from_reverse_ANI(l_rphone,
                                                                           l_uwq_multi_record_match,
                                                                           l_phone_id);
            IF l_customer_id IS NOT NULL THEN
               p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'" uwq_multi_record_match='
                                 ||NVL(l_uwq_multi_record_match,'""')||' uwq_reverse_ani="'||l_rphone||'"';
               p_action_param := p_action_param||'uwq_phone_id="'||l_phone_id ||'"';
               p_action_param := p_action_param||'uwq_complete_phone_num="'||l_complete_phone_num ||'"';
               RETURN;
            END IF;
         END IF;
      end if;

      l_value := get_media_value('ContactNum');
      IF l_value IS NOT NULL THEN
         l_customer_id := null;
         l_customer_id := CSC_ROUTING_UTL.Get_Customer_From_CustomerNum( p_party_number   => l_value);
         IF l_customer_id IS NOT NULL THEN
            p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'"';
            RETURN;
         END IF;
      END IF;

      --Since none of the other data worked, use the ANI phone number which is always present
      l_value := get_media_value('occtANI');
      IF l_value IS NOT NULL THEN

         --Note: standard REVERSE function cannot be used in PL-SQL as it is a reserved word in PL-SQL
         --to replace this function REVERSE_NUMBER function was created
         l_customer_id := NULL;
         l_rphone := HZ_PHONE_NUMBER_PKG.transpose(l_value);
         l_customer_id := CSC_ROUTING_UTL.get_customer_from_reverse_ANI(l_rphone,
                                                                        l_uwq_multi_record_match,
                                                                        l_phone_id);
         p_action_param := p_action_param||'uwq_party_id="'||l_customer_id ||'" uwq_multi_record_match='
                           ||NVL(l_uwq_multi_record_match,'""')||' uwq_reverse_ani="'||l_rphone||'"';
         p_action_param := p_action_param||'uwq_phone_id="'||l_phone_id ||'"';
         RETURN;
      END IF;
      p_action_param := p_action_param||'uwq_party_id="'||l_dummy_customer_id ||'"';

   END IF;
END IF; --new R12 end if
EXCEPTION
   WHEN OTHERS THEN
      p_action_param := p_action_param||'uwq_party_id="'||l_dummy_customer_id ||'"';

END CSC_UWQ_FORM_OBJ;

END CSC_UWQ_FORM_ROUTE;

/
