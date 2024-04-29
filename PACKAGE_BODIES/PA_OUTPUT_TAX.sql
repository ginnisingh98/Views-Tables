--------------------------------------------------------
--  DDL for Package Body PA_OUTPUT_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OUTPUT_TAX" as
/* $Header: PAXOTAXB.pls 120.12.12010000.8 2010/01/29 05:35:00 dlella ship $ */

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/*Added the two parameters bill_to_customer_id and ship_to_customer_id
  for customer account relation enhancement bug no 2760630*/

PROCEDURE GET_DEFAULT_TAX_INFO
           ( P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Event_id                        IN   NUMBER ,
             P_Expenditure_item_id             IN   NUMBER ,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             X_Output_tax_exempt_flag         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_tax_exempt_number       OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_exempt_reason_code      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_tax_code                OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             Pbill_to_customer_id             IN   NUMBER,
             Pship_to_customer_id             IN   NUMBER,
             P_draft_inv_num_credited          IN   NUMBER DEFAULT NULL,
	     P_invoice_date                    IN   DATE DEFAULT SYSDATE) /* bug 5484859 */

IS
  l_tax_code             Varchar2(30);
  l_line_type            Varchar2(20);
  l_vat_tax_id           Number;
  l_reason_code          Varchar2(80);
  l_certificate_no       Varchar2(80);
  l_exemption_id         Number;
  l_percent_exempt        Number;
  l_inserted_flag         Varchar2(1);
  l_exemption_type        Varchar2(100);

  l_transaction_type_id   NUMBER;
  l_batch_source_id       NUMBER;
  l_legal_entity_id       NUMBER;

  l_return_status       VARCHAR2(30);

  l_bill_to_party_id   NUMBER;
  l_bill_to_party_site_id NUMBER;
  l_ship_to_party_id  NUMBER;
  l_ship_to_party_site_id NUMBER;

  l_bill_to_address_id number;
  l_ship_to_address_id number;


  l_org_id               NUMBER; --eTax changes

  l1_exemption_rec_tbl    ZX_TCM_GET_DEF_EXEMPTION.exemption_rec_tbl_type;

  --eTax changes
  CURSOR get_org_id(c_project_id NUMBER) IS
    select org_id from pa_projects_all
      where project_id = c_project_id;

BEGIN
-- Determine the invoice line type

   If   nvl(P_Event_id,0)=0     -- Event id is null
   and  nvl(P_Expenditure_item_id,0) = 0 -- Expenditure Item id is NULL
   Then
        l_line_type := 'RETENTION';
   Elsif nvl(P_Event_id,0)<> 0
   and   nvl(P_Expenditure_item_id,0) =0
   Then
        l_line_type := 'EVENT';
   Elsif nvl(P_Event_id,0)=0
   and   nvl(P_Expenditure_item_id,0)<> 0
   Then
        l_line_type := 'EXPENDITURE';
   End If;

-- Set the draft Invoice Number for Client Extension Validation
   PA_Tax_Client_Extn_Drv.G_Draft_Invoice_Num := P_Draft_Inv_Num ;

   /* Added for Bug 6524843 */
   PA_Tax_Client_Extn_Drv.G_Invoice_Date := P_invoice_date ;

-- Call Default Tax API
/*Changed the parameter p_customer_id p_primary_customer_id
  and added two_new parameters pbill_to_customer_id and pship_to_customer_id
  for customer account relation enhancement*/

   --etax changes
   Open get_org_id(p_project_id);
   Fetch get_org_id into l_org_id;
   Close get_org_id;

   IF g1_debug_mode  = 'Y' THEN
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' get_pa_default_classification: Org_id: '||l_org_id);
   END IF;

   IF g1_debug_mode  = 'Y' THEN
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' calling ZX_AR_TAX_CLASSIFICATN_DEF_PKG' );
     PA_MCB_INVOICE_PKG.log_message('p_project_id              : ' || P_Project_Id );
     PA_MCB_INVOICE_PKG.log_message('p_bill_to_site_use_id     : ' || P_Bill_to_site_use_id );
     PA_MCB_INVOICE_PKG.log_message('p_ship_to_site_use_id     : ' || P_Ship_to_site_use_id );
     PA_MCB_INVOICE_PKG.log_message('p_project_customer_id     : ' || P_Customer_Id );
     PA_MCB_INVOICE_PKG.log_message('p_set_of_books_id         : ' || P_Sets_of_books_id );
     PA_MCB_INVOICE_PKG.log_message('p_expenditure_item_id     : ' || P_Expenditure_item_id );
     PA_MCB_INVOICE_PKG.log_message('p_trx_date                : ' || trunc(sysdate) );
     PA_MCB_INVOICE_PKG.log_message('p_event_id                : ' || P_Event_id );
     PA_MCB_INVOICE_PKG.log_message('p_line_type               : ' || l_line_type );
     PA_MCB_INVOICE_PKG.log_message('p_request_id              : ' || P_Request_id );
     PA_MCB_INVOICE_PKG.log_message('p_user_id                 : ' || P_User_Id );
     PA_MCB_INVOICE_PKG.log_message('p_tax_classification_code : ' || l_tax_code );
     PA_MCB_INVOICE_PKG.log_message('p_bill_to_customer_id     : ' || Pbill_to_customer_id );
     PA_MCB_INVOICE_PKG.log_message('p_ship_to_customer_id     : ' || Pship_to_customer_id );
     PA_MCB_INVOICE_PKG.log_message('p_application_id          : ' || 275 );
     PA_MCB_INVOICE_PKG.log_message('p_internal_organization_id: ' || l_org_id );
     PA_MCB_INVOICE_PKG.log_message('p_draft_inv_num_credited  : ' || p_draft_inv_num_credited );

   END IF;

   ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_pa_default_classification
   (
    p_project_id            => P_Project_Id,
    p_bill_to_site_use_id   => P_Bill_to_site_use_id,
    p_ship_to_site_use_id   => P_Ship_to_site_use_id,
    p_project_customer_id   => P_Customer_Id,
    p_set_of_books_id       => P_Sets_of_books_id,
    p_expenditure_item_id   => P_Expenditure_item_id,
    /*p_trx_date            => trunc(sysdate), */
    p_trx_date              => trunc(P_invoice_date), /* Sending trx_date as inv_date for bug 5484859 */
    p_event_id              => P_Event_id,
    p_line_type             => l_line_type,
    p_request_id            => P_Request_id,
    p_user_id               => P_User_Id,
    p_tax_classification_code => l_tax_code,
    p_bill_to_customer_id   => Pbill_to_customer_id,
    p_ship_to_customer_id   => Pship_to_customer_id,
    p_application_id        => 275,
    p_internal_organization_id => l_org_id
    );

   IF g1_debug_mode  = 'Y' THEN
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' done ZX_AR_TAX_CLASSIFICATN_DEF_PKG' );
     PA_MCB_INVOICE_PKG.log_message('p_tax_classification_code : ' || l_tax_code );
   END IF;
-- If Tax_code is null , Return from the procedure
       X_Output_tax_exempt_flag     := 'S'; /* added this for bug 7229135*/
   If  l_tax_code IS NULL
   Then
--       X_Output_vat_tax_id          := NULL; --commented by hsiu
--       X_Output_tax_exempt_flag     := 'S'; commented this for bug 7229135
       X_Output_tax_exempt_number   := NULL;
       X_Output_exempt_reason_code  := NULL;
       Return;
   ELSE
      x_output_tax_code := l_tax_code;
   End If;

-- Call Exemption API to get the exemption information

/*Added the two parameters bill_to_customer_id and ship_to_customer_id
  for customer account relation enhancement bug no 2760630*/
/*
   IF g1_debug_mode  = 'Y' THEN
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' calling ARP_STAX' );
   END IF;



   ARP_STAX.find_tax_exemption_id
   (
     bill_to_customer_id         => Pbill_to_customer_id,
     ship_to_customer_id         => Pship_to_customer_id,
     ship_to_site_id             => P_Ship_to_site_use_id,
     tax_code                    => l_tax_code,
     inventory_item_id           => NULL,
     tax_exempt_flag             => 'S',
     trx_date                    => trunc(sysdate),
     reason_code                 => l_reason_code,
     certificate                 => l_certificate_no,
     percent_exempt              => l_percent_exempt,
     inserted_flag               => l_inserted_flag,
     exemption_type              => l_exemption_type,
     tax_exemption_id            => l_exemption_id);
*/

   IF g1_debug_mode  = 'Y' THEN
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' getting  bill party info' );
   END IF;

     select hz_c.party_id, hz_cs.party_site_id, pc.bill_to_address_id
     into  l_bill_to_party_id, l_bill_to_party_site_id, l_bill_to_address_id
     from hz_cust_accounts hz_c, hz_cust_acct_sites hz_cs, pa_project_customers pc
     where pc.project_id = p_project_id
     and pc.customer_id = p_customer_id
     and hz_cs.cust_acct_site_id = pc.bill_to_address_id
     and hz_c.cust_account_id = p_customer_id;

   IF g1_debug_mode  = 'Y' THEN
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'bill partyid :' ||
                                     l_bill_to_party_id ||  ';bill party site id :' ||
                                     l_bill_to_party_site_id || ';bill address id :' || l_bill_to_address_id);

     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' getting  ship party info' );
   END IF;

     select hz_c.party_id, hz_cs.party_site_id, pc.ship_to_address_id
     into  l_ship_to_party_id, l_ship_to_party_site_id, l_ship_to_address_id
     from hz_cust_accounts hz_c, hz_cust_acct_sites hz_cs, pa_project_customers pc
     where pc.project_id = p_project_id
     and pc.customer_id = p_customer_id
     and hz_cs.cust_acct_site_id = pc.ship_to_address_id
     and hz_c.cust_account_id = p_customer_id;

   IF g1_debug_mode  = 'Y' THEN
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'ship partyid :' ||
                                     l_ship_to_party_id ||  ';ship party site id :' ||
                                     l_ship_to_party_site_id || ';ship address id :' || l_ship_to_address_id);
     PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' calling  get_btch_src_trans_type' );
   END IF;

     get_btch_src_trans_type ( p_project_id               => p_project_id,
                               p_draft_invoice_num        => p_draft_inv_num,
                               p_draft_inv_num_credited   => p_draft_inv_num_credited,
                               x_transaction_type_id      => l_transaction_type_id,
                               x_batch_source_id          =>  l_batch_source_id,
                               x_return_status            =>  l_return_status);

      IF g1_debug_mode  = 'Y' THEN

        PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' done get_btch_src_trans_type' );
        PA_MCB_INVOICE_PKG.log_message('return status : ' || l_return_status );

      END IF;

     get_legal_entity_id (p_customer_id          => nvl(Pbill_to_customer_id, p_customer_id),
                          p_org_id               => l_org_id,
                          p_transaction_type_id  => l_transaction_type_id,
                          p_batch_source_id      => l_batch_source_id,
                          x_legal_entity_id      => l_legal_entity_id,
                          x_return_status        => l_return_status);

      IF g1_debug_mode  = 'Y' THEN

        PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' done get_legal_entity_id' );
        PA_MCB_INVOICE_PKG.log_message('return status : ' || l_return_status );

      END IF;

     IF g1_debug_mode  = 'Y' THEN

        PA_MCB_INVOICE_PKG.log_message('=====Parameters for get_default_exemptions====' );
        PA_MCB_INVOICE_PKG.log_message('p_bill_to_cust_acct_id' || Pbill_to_customer_id );
        PA_MCB_INVOICE_PKG.log_message('p_ship_to_cust_acct_id' || Pship_to_customer_id );
        PA_MCB_INVOICE_PKG.log_message('p_ship_to_site_use_id' || P_ship_to_site_use_id );
        PA_MCB_INVOICE_PKG.log_message('p_bill_to_site_use_id' || P_bill_to_site_use_id );
        PA_MCB_INVOICE_PKG.log_message('p_bill_to_party_id' || l_bill_to_party_id );
        PA_MCB_INVOICE_PKG.log_message('p_bill_to_party_site_id' || l_bill_to_party_site_id );
        PA_MCB_INVOICE_PKG.log_message('p_ship_to_party_site_id' || l_ship_to_party_site_id );
        PA_MCB_INVOICE_PKG.log_message('p_legal_entity_id' || l_legal_entity_id );
        PA_MCB_INVOICE_PKG.log_message('p_org_id' || l_org_id );
        PA_MCB_INVOICE_PKG.log_message('p_trx_date' || trunc(sysdate) );
        PA_MCB_INVOICE_PKG.log_message('p_exempt_certificate_number' || l_certificate_no );
        PA_MCB_INVOICE_PKG.log_message('p_reason_code' || l_reason_code );


     END IF;

/* Commenting for bug 7187173 as PA only deals with PRIMARY exemptions (p_exempt_control_flag='S')
   All other cases of exepmtions will be handled by the ETax code while deriving Tax information
   in Receivables.

     ZX_TCM_GET_DEF_EXEMPTION.get_default_exemptions
                 (p_bill_to_cust_acct_id          => Pbill_to_customer_id,
                  p_ship_to_cust_acct_id          => Pship_to_customer_id,
                  p_ship_to_site_use_id           => p_ship_to_site_use_id,
                  p_bill_to_site_use_id           => p_bill_to_site_use_id,
                  p_bill_to_party_id              => l_bill_to_party_id,
                  p_bill_to_party_site_id         => l_bill_to_party_site_id,
                  p_ship_to_party_site_id         => l_ship_to_party_site_id,
                  p_legal_entity_id               => l_legal_entity_id,
                  p_org_id                        => l_org_id,
                  p_trx_date                      => trunc(sysdate),
                  p_exempt_certificate_number     => l_certificate_no,
                  p_reason_code                   => l_reason_code,
                  p_exempt_control_flag           => 'S',
                  p_inventory_org_id              => NULL,
                  p_inventory_item_id             => NULL ,
                  x_return_status                 => l_return_status ,
                  x_exemption_rec_tbl             => l1_exemption_rec_tbl);

      IF g1_debug_mode  = 'Y' THEN

        PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' done get_default_exemptions' );
        PA_MCB_INVOICE_PKG.log_message('return status : ' || l_return_status );
        PA_MCB_INVOICE_PKG.log_message('exemption_rec_tbl count:' || l1_exemption_rec_tbl.COUNT );

      END IF;

      IF l1_exemption_rec_tbl.COUNT > 0 THEN

         IF g1_debug_mode  = 'Y' THEN

            PA_MCB_INVOICE_PKG.log_message('tax exempt id :' || l1_exemption_rec_tbl(1).tax_exemption_id);
            PA_MCB_INVOICE_PKG.log_message('exmpt cert no :'   || l1_exemption_rec_tbl(1).exempt_certificate_number );
            PA_MCB_INVOICE_PKG.log_message('exmpt reason code :' || l1_exemption_rec_tbl(1).exempt_reason_code );

         END IF;
         l_exemption_id := l1_exemption_rec_tbl(1).tax_exemption_id;
         l_certificate_no := l1_exemption_rec_tbl(1).exempt_certificate_number;
         l_reason_code := l1_exemption_rec_tbl(1).exempt_reason_code;

      ELSE

         l_exemption_id := NULL;

      END IF;
-- Assign Tax Code to output

--   X_Output_vat_tax_id  := l_vat_tax_id; --commented by hsiu

-- If  No exemption exist
   If  l_exemption_id IS NULL
   Then
       X_Output_tax_exempt_flag       := 'S';
       X_Output_tax_exempt_number     := NULL;
       X_Output_exempt_reason_code    := NULL;
   Else
 -- If Exemption exists
       X_Output_tax_exempt_flag       := 'E';
       X_Output_tax_exempt_number     := l_certificate_no;
       X_Output_exempt_reason_code    := l_reason_code;
   End If;
end Commenting for bug 7187173 */

EXCEPTION
   When OTHERS Then
         X_Output_tax_exempt_flag    := NULL; --NOCOPY
         X_Output_tax_exempt_number := NULL; --NOCOPY
         X_Output_exempt_reason_code := NULL; --NOCOPY
         X_Output_tax_code           := NULL; --NOCOPY
      PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || SQLERRM );
        Raise;
END GET_DEFAULT_TAX_INFO;

/* Overloaded procedure added for Customer Relationship Management enhancement */
PROCEDURE GET_DEFAULT_TAX_INFO
           ( P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Event_id                        IN   NUMBER ,
             P_Expenditure_item_id             IN   NUMBER ,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             X_Output_tax_exempt_flag         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_tax_exempt_number       OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_exempt_reason_code      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             X_Output_Tax_code                OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	     P_invoice_date                   IN   DATE default SYSDATE)  /* bug 5484859 */
Is
new_excp	exception;
Begin

Raise new_excp;

End GET_DEFAULT_TAX_INFO;

/*ADDED  OVERLOADED PROCEDURE*/

PROCEDURE MARK_CUST_REV_DIST_LINES (
             P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
             P_agreement_id                     IN   NUMBER ,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Expenditure_item_id             IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_Line_num                        IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             P_No_of_rec                       IN   NUMBER ,
             X_Rec_upd                        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
             P_bill_trans_currency_code        IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_bill_trans_invoice_amount       IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_bill_trans_bill_amount          IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_invoice_amount          IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_bill_amount             IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             p_retention_percentage            IN   VARCHAR2,
             P_status_code                     IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invoice_date                    IN    VARCHAR2,
             x_return_status                   IN OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
new_excp        exception;
Begin

Raise new_excp;

END  MARK_CUST_REV_DIST_LINES;
/*END OF OVERLOADED PROCEDURE*/
/*Added the two parameters bill_to_customer_id and ship_to_customer_id
  for customer account relation enhancement bug no 2760630*/
PROCEDURE MARK_CUST_REV_DIST_LINES (
             P_Project_Id                      IN   NUMBER ,
             P_Draft_Inv_Num                   IN   NUMBER ,
             P_Customer_Id                     IN   NUMBER ,
             P_agreement_id                     IN   NUMBER ,
             P_Bill_to_site_use_id             IN   NUMBER ,
             P_Ship_to_site_use_id             IN   NUMBER ,
             P_Sets_of_books_id                IN   NUMBER ,
             P_Expenditure_item_id             IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_Line_num                        IN   PA_PLSQL_DATATYPES.IdTabTyp,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             P_No_of_rec                       IN   NUMBER ,
             X_Rec_upd                        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
	     P_bill_trans_currency_code        IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_bill_trans_invoice_amount       IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_bill_trans_bill_amount          IN   PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_invoice_amount          IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invproc_bill_amount             IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             p_retention_percentage            IN   VARCHAR2,
             P_status_code                     IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_invoice_date                    IN    VARCHAR2,
             Pbill_to_customer_id              IN    NUMBER,
             Pship_to_customer_id              IN    NUMBER,
             P_shared_funds_consumption        IN   NUMBER, /* Federal  */
             P_expenditure_item_date            IN  PA_PLSQL_DATATYPES.Char30TabTyp, /* Federal */
             x_return_status                   IN OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
 loop_index                    NUMBER;
 l_count                       NUMBER := 0;
 l_Output_vat_tax_id           NUMBER;
 l_output_tax_code             VARCHAR2(30); --added by hsiu for eTax changes
 l_Output_tax_exempt_flag      VARCHAR2(1);
--Modified for Bug3128094
 l_Output_tax_exempt_number    VARCHAR2(80);
 l_Output_exempt_reason_code   VARCHAR2(30);
--till here for Bug3128094

-- MCB Related Variables

 l_multi_currency_billing_flag VARCHAR2(1);
 l_baseline_funding_flag       VARCHAR2(1);
 l_revproc_currency_code       VARCHAR2(30);
 l_invproc_currency_code       VARCHAR2(30);
 l_project_currency_code       VARCHAR2(30);
 l_project_rate_date_code      VARCHAR2(30);
 l_project_rate_type       	VARCHAR2(30);
 l_project_rate_date       	DATE;
 l_project_exchange_rate   	NUMBER;
 l_projfunc_currency_code      VARCHAR2(30);
 l_projfunc_rate_date_code 	VARCHAR2(30);
 l_projfunc_rate_type      	VARCHAR2(30);
 l_projfunc_rate_date      	DATE;
 l_projfunc_exchange_rate  	NUMBER;
 l_funding_rate_date_code      VARCHAR2(30);
 l_funding_rate_type           VARCHAR2(30);
 l_funding_rate_date           DATE;
 l_funding_exchange_rate       NUMBER;
 l_funding_currency_code       VARCHAR2(30);
 l_return_status               VARCHAR2(30);
 l_msg_count                   NUMBER;
 l_msg_data                    VARCHAR2(240);


 tmp_denominator_tab           PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_numerator_tab             PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_rate_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_user_validate_flag_tab    PA_PLSQL_DATATYPES.Char30TabTyp;

 tmp_status_project_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_status_projfunc_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_status_funding_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_status_tab                PA_PLSQL_DATATYPES.Char30TabTyp;

 tmp_project_bill_amount       PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_projfunc_bill_amount      PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_funding_bill_amount       PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_invproc_bill_amount       PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_bill_trans_bill_amount    PA_PLSQL_DATATYPES.NumTabTyp;

 tmp_project_exchange_rate     PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_projfunc_exchange_rate    PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_funding_exchange_rate     PA_PLSQL_DATATYPES.NumTabTyp;
 tmp_invproc_exchange_rate     PA_PLSQL_DATATYPES.NumTabTyp;

 tmp_project_rate_type         PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_projfunc_rate_type        PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_invproc_rate_type         PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_funding_rate_type         PA_PLSQL_DATATYPES.Char30TabTyp;

 tmp_project_rate_date         PA_PLSQL_DATATYPES.DateTabTyp;
 tmp_projfunc_rate_date        PA_PLSQL_DATATYPES.DateTabTyp;
 tmp_funding_rate_date         PA_PLSQL_DATATYPES.DateTabTyp;
 tmp_invproc_rate_date         PA_PLSQL_DATATYPES.DateTabTyp;

 tmp_project_currency_code     PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_funding_currency_code     PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_projfunc_currency_code    PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_invproc_currency_code     PA_PLSQL_DATATYPES.Char30TabTyp;
 tmp_invproc_currency_type     VARCHAR2(30);

 tmp_invoice_eligible_flag     VARCHAR2(1) :='Y';

 l_request_id                  NUMBER:= fnd_global.conc_request_id;
 l_program_id                  NUMBER:= fnd_global.conc_program_id;
 l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
 l_program_update_date         DATE  := sysdate;
 l_retention_percentage	       NUMBER:= NVL(TO_NUMBER(p_retention_percentage),0);
 l_err_count                   NUMBER := 0;


/* Federal Changes */

 l_agreement_start_date       DATE;
 l_agreement_exp_date         DATE;
 tmp_expenditure_item_date    PA_PLSQL_DATATYPES.DateTabTyp;

BEGIN

     -- Multicurrency Related Changes
     -- Convert the Bill Transaction Curreny to IPC

     -- Get the Project level defaults
     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Inside MARK_CUST_REV_DIST_LINES');
     	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Call PA_MULTI_CURRENCY_BILLING.get_project_defaults');
     END IF;

     PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  => p_project_id,
            x_multi_currency_billing_flag => l_multi_currency_billing_flag,
            x_baseline_funding_flag       => l_baseline_funding_flag,
            x_revproc_currency_code       => l_revproc_currency_code,
	    x_invproc_currency_type       => tmp_invproc_currency_type,
            x_invproc_currency_code       => l_invproc_currency_code,
            x_project_currency_code       => l_project_currency_code,
            x_project_bil_rate_date_code  => l_project_rate_date_code,
            x_project_bil_rate_type       => l_project_rate_type,
            x_project_bil_rate_date       => l_project_rate_date,
            x_project_bil_exchange_rate   => l_project_exchange_rate,
            x_projfunc_currency_code      => l_projfunc_currency_code,
            x_projfunc_bil_rate_date_code => l_projfunc_rate_date_code,
            x_projfunc_bil_rate_type      => l_projfunc_rate_type,
            x_projfunc_bil_rate_date      => l_projfunc_rate_date,
            x_projfunc_bil_exchange_rate  => l_projfunc_exchange_rate,
            x_funding_rate_date_code      => l_funding_rate_date_code,
            x_funding_rate_type           => l_funding_rate_type,
            x_funding_rate_date           => l_funding_rate_date,
            x_funding_exchange_rate       => l_funding_exchange_rate,
            x_return_status               => l_return_status,
            x_msg_count                   => l_msg_count,
            x_msg_data                    => l_msg_data);

     IF l_funding_currency_code IS NULL THEN

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Get Funding Currency Code ');
        END IF;

        BEGIN


                 /* Federal Changes : Added start date and expiry date */

		SELECT agreement_currency_code,
     	               nvl(start_date,to_date('01/01/1952', 'DD/MM/YYYY')),
                       nvl(expiration_date,sysdate)
                 INTO  l_funding_currency_code,
                       l_agreement_start_date, l_agreement_exp_date
	         FROM  PA_AGREEMENTS_ALL
		WHERE  agreement_id = p_agreement_id;

 	        IF g1_debug_mode  = 'Y' THEN
 	        	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'Funding Currency Code  : ' || l_funding_currency_code);
 	        END IF;

	EXCEPTION

		WHEN NO_DATA_FOUND THEN
 	       		IF g1_debug_mode  = 'Y' THEN
 	       			PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Oracle Error NO DATA FOUND');
 	       		END IF;
			RAISE ;
        END ;

     END IF;


     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Loop Begins for ' || P_No_of_rec);
     END IF;

     FOR loop_index in 1..P_No_of_rec LOOP

	tmp_project_currency_code(loop_index)  := l_project_currency_code;
	tmp_project_rate_type(loop_index)      := l_project_rate_type;
	tmp_project_exchange_rate(loop_index)  := l_project_exchange_rate;

	IF l_project_rate_date_code ='FIXED' THEN
	     tmp_project_rate_date(loop_index)      := l_project_rate_date;
	ELSE
	     if l_project_rate_date IS NULL THEN
	         tmp_project_rate_date(loop_index)      := TO_DATE(p_invoice_date,'YYYY/MM/DD');
             else
                 tmp_project_rate_date(loop_index)      := l_project_rate_date;
	     end if;
	END IF;


	tmp_projfunc_currency_code(loop_index)  := l_projfunc_currency_code;
	tmp_projfunc_rate_type(loop_index)      := l_projfunc_rate_type;
	tmp_projfunc_exchange_rate(loop_index)  := l_projfunc_exchange_rate;

	IF l_projfunc_rate_date_code ='FIXED' THEN
		tmp_projfunc_rate_date(loop_index)      := l_projfunc_rate_date;
	ELSE
	     if l_projfunc_rate_date IS NULL THEN
	         tmp_projfunc_rate_date(loop_index)      := TO_DATE(p_invoice_date,'YYYY/MM/DD');
             else
                 tmp_projfunc_rate_date(loop_index)      := l_projfunc_rate_date;
	     end if;
	END IF;


	tmp_funding_currency_code(loop_index) := l_funding_currency_code;
	tmp_funding_rate_type(loop_index)      := l_funding_rate_type;
	tmp_funding_exchange_rate(loop_index)  := l_funding_exchange_rate;

	IF l_funding_rate_date_code ='FIXED' THEN
		tmp_funding_rate_date(loop_index)  := l_funding_rate_date;
	ELSE
	     if l_funding_rate_date IS NULL THEN
	         tmp_funding_rate_date(loop_index)      := TO_DATE(p_invoice_date,'YYYY/MM/DD');
             else
                 tmp_funding_rate_date(loop_index)      := l_funding_rate_date;
	     end if;
	END IF;


        tmp_denominator_tab(loop_index)       :=0;
        tmp_numerator_tab(loop_index)         :=0;
        tmp_rate_tab(loop_index)              :=0;
        tmp_user_validate_flag_tab(loop_index):='N';
        tmp_status_project_tab(loop_index)    :='N';
        tmp_status_projfunc_tab(loop_index)   :='N';
        tmp_status_funding_tab(loop_index)    := 'N';
        tmp_status_tab(loop_index)            := 'N';

        tmp_project_bill_amount(loop_index)   :=0;
        tmp_projfunc_bill_amount(loop_index)  :=0;
        tmp_invproc_bill_amount(loop_index)   :=0;
        tmp_funding_bill_amount(loop_index)   :=0;
        tmp_bill_trans_bill_amount(loop_index):= TO_NUMBER(p_bill_trans_invoice_amount(loop_index));
        tmp_expenditure_item_date(loop_index)  := TO_DATE(p_expenditure_item_date(loop_index),'YYYY/MM/DD'); /* Federal Changes */


        IF tmp_invproc_currency_type = 'FUNDING_CURRENCY' THEN
	   tmp_invproc_rate_type(loop_index) := tmp_funding_rate_type(loop_index);
	   tmp_invproc_rate_date(loop_index) := tmp_funding_rate_date(loop_index);
	   tmp_invproc_exchange_rate(loop_index) := tmp_funding_exchange_rate(loop_index);
	   tmp_invproc_currency_code(loop_index) := tmp_funding_currency_code(loop_index);
        ELSIF tmp_invproc_currency_type = 'PROJECT_CURRENCY' THEN
	   tmp_invproc_rate_type(loop_index) := tmp_project_rate_type(loop_index);
	   tmp_invproc_rate_date(loop_index) := tmp_project_rate_date(loop_index);
	   tmp_invproc_exchange_rate(loop_index) := tmp_project_exchange_rate(loop_index);
	   tmp_invproc_currency_code(loop_index) := tmp_project_currency_code(loop_index);
        ELSIF tmp_invproc_currency_type = 'PROJFUNC_CURRENCY' THEN
	   tmp_invproc_rate_type(loop_index) := tmp_projfunc_rate_type(loop_index);
	   tmp_invproc_rate_date(loop_index) := tmp_projfunc_rate_date(loop_index);
	   tmp_invproc_exchange_rate(loop_index) := tmp_projfunc_exchange_rate(loop_index);
	   tmp_invproc_currency_code(loop_index) := tmp_projfunc_currency_code(loop_index);
	END IF;


     END LOOP;

     IF p_bill_trans_currency_code.COUNT <> 0 THEN

        -- Convert the bill transaction currecy to PFC
 	IF g1_debug_mode  = 'Y' THEN
 		PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Conversion CALL for BTC to PF ');
 	END IF;

        PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                                        p_from_currency_tab             => p_bill_trans_currency_code,
                                        p_to_currency_tab               => tmp_projfunc_currency_code,
                                        p_conversion_date_tab           => tmp_projfunc_rate_date,
                                        p_conversion_type_tab           => tmp_projfunc_rate_type,
                                        p_amount_tab                    => tmp_bill_trans_bill_amount,
                                        p_user_validate_flag_tab        => tmp_user_validate_flag_tab,
                                        p_converted_amount_tab          => tmp_projfunc_bill_amount,
                                        p_denominator_tab               => tmp_denominator_tab,
                                        p_numerator_tab                 => tmp_numerator_tab,
                                        p_rate_tab                      => tmp_projfunc_exchange_rate,
                                        x_status_tab                    => tmp_status_projfunc_tab,
					p_conversion_between		=> 'BTC_PF',
					p_cache_flag			=>'Y');

       IF l_project_currency_code = l_projfunc_currency_code then

            IF g1_debug_mode  = 'Y' THEN
            	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'Proj curr = Proj func currency ..Copy ' );
            END IF;

            FOR i IN tmp_status_projfunc_tab.FIRST..tmp_status_projfunc_tab.LAST LOOP

                tmp_project_rate_date(i) :=  tmp_projfunc_rate_date(i);
                tmp_project_rate_type(i) :=  tmp_projfunc_rate_type(i);
                tmp_project_bill_amount(i) := tmp_projfunc_bill_amount(i);
                tmp_project_exchange_rate(i) :=  tmp_projfunc_exchange_rate(i);
                tmp_status_project_tab(i) :=  tmp_status_projfunc_tab(i);

            END LOOP;

       else

            -- Convert the bill transaction currecy to PC
 	    IF g1_debug_mode  = 'Y' THEN
 	    	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Conversion CALL for BTC to PC ');
 	    END IF;

            PA_MULTI_CURRENCY_BILLING.convert_amount_bulk(
                                        p_from_currency_tab             => p_bill_trans_currency_code,
                                        p_to_currency_tab               => tmp_project_currency_code,
                                        p_conversion_date_tab           => tmp_project_rate_date,
                                        p_conversion_type_tab           => tmp_project_rate_type,
                                        p_amount_tab                    => tmp_bill_trans_bill_amount,
                                        p_user_validate_flag_tab        => tmp_user_validate_flag_tab,
                                        p_converted_amount_tab          => tmp_project_bill_amount,
                                        p_denominator_tab               => tmp_denominator_tab,
                                        p_numerator_tab                 => tmp_numerator_tab,
                                        p_rate_tab                      => tmp_project_exchange_rate,
                                        x_status_tab                    => tmp_status_project_tab,
					p_conversion_between		=> 'BTC_PC',
					p_cache_flag			=>'Y');
       end if;

       IF l_funding_currency_code = l_projfunc_currency_code then

            IF g1_debug_mode  = 'Y' THEN
            	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'Fund curr = Proj func currency ..Copy ' );
            END IF;

            FOR i IN tmp_status_projfunc_tab.FIRST..tmp_status_projfunc_tab.LAST LOOP

                tmp_funding_rate_date(i) :=  tmp_projfunc_rate_date(i);
                tmp_funding_rate_type(i) :=  tmp_projfunc_rate_type(i);
                tmp_funding_bill_amount(i) := tmp_projfunc_bill_amount(i);
                tmp_funding_exchange_rate(i) :=  tmp_projfunc_exchange_rate(i);
                tmp_status_funding_tab(i) :=  tmp_status_projfunc_tab(i);

            END LOOP;

       elsif l_funding_currency_code = l_project_currency_code then

              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'funding curr = Proj currency ..Copy ' );
              END IF;

              FOR i IN tmp_status_project_tab.FIRST..tmp_status_project_tab.LAST LOOP

                  tmp_funding_rate_date(i) :=  tmp_project_rate_date(i);
                  tmp_funding_rate_type(i) :=  tmp_project_rate_type(i);
                  tmp_funding_bill_amount(i) := tmp_project_bill_amount(i);
                  tmp_funding_exchange_rate(i) :=  tmp_project_exchange_rate(i);
                  tmp_status_funding_tab(i) :=  tmp_status_project_tab(i);

              END LOOP;

       else

 	   IF g1_debug_mode  = 'Y' THEN
 	   	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Conversion CALL for BTC to FC ');
 	   END IF;

           PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                            p_from_currency_tab             => p_bill_trans_currency_code,
                            p_to_currency_tab               => tmp_funding_currency_code,
                            p_conversion_date_tab           => tmp_funding_rate_date,
                            p_conversion_type_tab           => tmp_funding_rate_type,
                            p_amount_tab                    => tmp_bill_trans_bill_amount,
                            p_user_validate_flag_tab        => tmp_user_validate_flag_tab,
                            p_converted_amount_tab          => tmp_funding_bill_amount,
                            p_denominator_tab               => tmp_denominator_tab,
                            p_numerator_tab                 => tmp_numerator_tab,
                            p_rate_tab                      => tmp_funding_exchange_rate,
                            x_status_tab                    => tmp_status_funding_tab,
			    p_conversion_between	    => 'BTC_FC',
			    p_cache_flag		    =>'Y');

           tmp_denominator_tab.delete;
           tmp_numerator_tab.delete;
       end if;

        /* Set the Invoice Processing Currency */

        IF tmp_invproc_currency_type = 'FUNDING_CURRENCY' THEN


 	   IF g1_debug_mode  = 'Y' THEN
 	   	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' invcurr = fund curr');
 	   END IF;
           FOR i IN 1..tmp_status_project_tab.COUNT LOOP

               tmp_invproc_bill_amount(i)   := tmp_funding_bill_amount(i);
               tmp_invproc_exchange_rate(i) := tmp_funding_exchange_rate(i);
               tmp_invproc_rate_date(i)     := tmp_funding_rate_date(i);
               tmp_invproc_rate_type(i)     := tmp_funding_rate_type(i);
               tmp_invproc_currency_code(i)     := tmp_funding_currency_code(i);

           END LOOP;

        ELSIF tmp_invproc_currency_type = 'PROJECT_CURRENCY' THEN

            -- Invoice Processing is PC
            -- Move the Project Currency Amount and attributes to  Invoice Processing

 	   IF g1_debug_mode  = 'Y' THEN
 	   	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' invcurr = proj curr');
 	   END IF;
            FOR i IN 1..tmp_status_project_tab.COUNT LOOP

               tmp_invproc_bill_amount(i)   := tmp_project_bill_amount(i);
               tmp_invproc_exchange_rate(i) := tmp_project_exchange_rate(i);
               tmp_invproc_rate_date(i)     := tmp_project_rate_date(i);
               tmp_invproc_rate_type(i)     := tmp_project_rate_type(i);
               tmp_invproc_currency_code(i)     := tmp_project_currency_code(i);

            END LOOP;

        ELSIF tmp_invproc_currency_type = 'PROJFUNC_CURRENCY' THEN

           -- Invoice Processing is PFC
           -- Move the Project Functional Currency Amount and attributes to Invoice Processing

 	   IF g1_debug_mode  = 'Y' THEN
 	   	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' invcurr = projfunc curr');
 	   END IF;
           FOR i IN 1..tmp_status_project_tab.COUNT LOOP

               tmp_invproc_bill_amount(i)   := tmp_projfunc_bill_amount(i);
               tmp_invproc_exchange_rate(i) := tmp_projfunc_exchange_rate(i);
               tmp_invproc_rate_date(i)     := tmp_projfunc_rate_date(i);
               tmp_invproc_rate_type(i)     := tmp_projfunc_rate_type(i);
               tmp_invproc_currency_code(i)     := tmp_projfunc_currency_code(i);

           END LOOP;

        END IF;

        -- Set the Status code array

 	   IF g1_debug_mode  = 'Y' THEN
 	   	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' setting status tab');
 	   END IF;
        FOR i IN 1..tmp_status_project_tab.COUNT LOOP

            tmp_status_tab(i) := 'N';
/*
            IF NVL(tmp_status_project_tab(i),'N') <> 'N' THEN
                  tmp_status_tab(i):= 'BTC_PROJ'|| tmp_status_project_tab(i);
            ELSIF NVL(tmp_status_projfunc_tab(i),'N') <> 'N' THEN
                  tmp_status_tab(i):= 'BTC_PROJFUNC_'|| tmp_status_projfunc_tab(i);
            ELSIF NVL(tmp_status_funding_tab(i),'N') <> 'N' THEN
                  tmp_status_tab(i):= 'BTC_FUNDING'|| tmp_status_funding_tab(i);
            END IF;
*/
 	    IF g1_debug_mode  = 'Y' THEN
 	    	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'proj' || tmp_status_project_tab(i));
 	    	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'projfunc' || tmp_status_projfunc_tab(i));
 	    	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'funding' || tmp_status_funding_tab(i));
 	    END IF;


/* Federal changes : begin  */
            IF ((p_shared_funds_consumption = 1) AND
                   (( tmp_expenditure_item_date(i) < l_agreement_start_date)  OR
                   ( tmp_expenditure_item_date(i)  > l_agreement_exp_date))) THEN
                   tmp_status_tab(i):= 'PA_EI_AGR_DATE_MISMATCH';
                   l_err_count := l_err_count + 1;
/* Federal Changes : End  */
            ELSIF NVL(tmp_status_project_tab(i),'N') <> 'N' THEN
                  tmp_status_tab(i):= tmp_status_project_tab(i);
                  l_err_count := l_err_count + 1;
            ELSIF NVL(tmp_status_projfunc_tab(i),'N') <> 'N' THEN
                  tmp_status_tab(i):= tmp_status_projfunc_tab(i);
                  l_err_count := l_err_count + 1;
            ELSIF NVL(tmp_status_funding_tab(i),'N') <> 'N' THEN
                  tmp_status_tab(i):= tmp_status_funding_tab(i);
                  l_err_count := l_err_count + 1;
            END IF;

        END LOOP;

     END IF;  /* Process only if the array has records */

     -- End of MCB changes

     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' calling get default tax info ');
     END IF;
     FOR loop_index in 1..P_No_of_rec LOOP

         -- Call Tax API to get the tax Id and Related attribute

/*Added the two parameters bill_to_customer_id and ship_to_customer_id
  for customer account relation enhancement bug no 2760630*/

         PA_OUTPUT_TAX.GET_DEFAULT_TAX_INFO
           ( P_Project_Id                      => P_Project_Id ,
             P_Draft_Inv_Num                   => P_Draft_Inv_Num ,
             P_Customer_Id                     => P_Customer_Id,
             P_Bill_to_site_use_id             => P_Bill_to_site_use_id,
             P_Ship_to_site_use_id             => P_Ship_to_site_use_id,
             P_Sets_of_books_id                => P_Sets_of_books_id,
             P_Event_id                        => NULL,
             P_Expenditure_item_id             => P_Expenditure_item_id(loop_index),
             P_User_Id                         => P_User_Id,
             P_Request_id                      => P_Request_id,
--             X_Output_vat_tax_id               => l_Output_vat_tax_id, --commented by hsiu
             X_output_tax_code                 => l_output_tax_code,
             X_Output_tax_exempt_flag          => l_Output_tax_exempt_flag,
             X_Output_tax_exempt_number        => l_Output_tax_exempt_number,
             X_Output_exempt_reason_code       => l_Output_exempt_reason_code,
             Pbill_to_customer_id              => Pbill_to_customer_id,
             Pship_to_customer_id              => Pship_to_customer_id,
	     P_invoice_date                    => to_date(P_invoice_date,'YYYY/MM/DD'));   /* passing invoice date for bug 5484859 */


	 tmp_invoice_eligible_flag :='Y';

	 IF  tmp_status_tab(loop_index) <> 'N' THEN

		tmp_invoice_eligible_flag := 'N';

	 END IF;

         -- Update the expenditure items

 	 IF g1_debug_mode  = 'Y' THEN
 	 	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'Update RDL and EI');
 	 	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'Expenditure Item ID  : ' || P_Expenditure_item_id(loop_index) );
 	 	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Funding Amount      : ' || tmp_funding_bill_amount(loop_index) );
 	 	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Project Amount      : ' || tmp_project_bill_amount(loop_index) );
 	 	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' ProjFunc Amount     : ' || tmp_projfunc_bill_amount(loop_index) );
 	 	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' Status Code         : ' || tmp_status_tab(loop_index) );
 	 END IF;

         Update PA_CUST_REV_DIST_LINES_ALL
         Set
	        -- invoice_eligible_flag            = tmp_invoice_eligible_flag, for bug 2649243, 2645634
                -- output_vat_tax_id                = l_Output_vat_tax_id, --commented by hsiu
                output_tax_classification_code   = l_output_tax_code,
                output_tax_exempt_flag           = l_Output_tax_exempt_flag,
                output_tax_exempt_reason_code    = l_Output_exempt_reason_code,
                output_tax_exempt_number         = l_Output_tax_exempt_number,
	        project_inv_rate_type	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_project_rate_type(loop_index), NULL),
	        project_inv_rate_date	     =
				DECODE(tmp_status_tab(loop_index),'N',
				--tmp_project_rate_date(loop_index), NULL), --Modified for Bug 3137196
				decode(tmp_project_rate_type(loop_index), 'User', null, tmp_project_rate_date(loop_index)), NULL),
	        project_inv_exchange_rate	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_project_exchange_rate(loop_index), NULL),
	        project_bill_amount	     	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_project_bill_amount(loop_index), NULL),
	        projfunc_inv_rate_type	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_projfunc_rate_type(loop_index), NULL),
	        projfunc_inv_rate_date	     =
				DECODE(tmp_status_tab(loop_index),'N',
				--tmp_projfunc_rate_date(loop_index), NULL), --Modified for Bug 3137196
				decode(tmp_projfunc_rate_type(loop_index), 'User', null, tmp_projfunc_rate_date(loop_index)), NULL),
	        projfunc_inv_exchange_rate	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_projfunc_exchange_rate(loop_index), NULL),
	        projfunc_bill_amount	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_projfunc_bill_amount(loop_index), NULL),
	    invproc_rate_type	             =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_invproc_rate_type(loop_index), NULL),
	    invproc_rate_date     	     =
				DECODE(tmp_status_tab(loop_index),'N',
				--tmp_invproc_rate_date(loop_index), NULL), --Modified for Bug 3137196
				decode(tmp_invproc_rate_type(loop_index), 'User', null, tmp_invproc_rate_date(loop_index)), NULL),
	    invproc_exchange_rate	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_invproc_exchange_rate(loop_index), NULL),
	    bill_amount	     		     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_invproc_bill_amount(loop_index), NULL),
	    funding_inv_rate_type	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_funding_rate_type(loop_index), NULL),
	    funding_inv_rate_date     	     =
				DECODE(tmp_status_tab(loop_index),'N',
				--tmp_funding_rate_date(loop_index), NULL), --Modified for Bug 3137196
				decode(tmp_funding_rate_type(loop_index), 'User', null, tmp_funding_rate_date(loop_index)), NULL),
	    funding_inv_exchange_rate	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_funding_exchange_rate(loop_index), NULL),
	    project_currency_code	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_project_currency_code(loop_index), NULL),
	    projfunc_currency_code	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_projfunc_currency_code(loop_index), NULL),
	    invproc_currency_code	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_invproc_currency_code(loop_index), NULL),
	    funding_currency_code	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_funding_currency_code(loop_index), NULL),
	    funding_bill_amount	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_funding_bill_amount(loop_index), NULL),
	    inv_gen_rejection_code	     = tmp_status_tab(loop_index),
	    request_id			     = P_Request_id,
            program_id			     = l_program_id,
            program_application_id	     = l_program_application_id,
            program_update_date		     = l_program_update_date
    Where   expenditure_item_id              = P_Expenditure_item_id(loop_index)
    and     line_num                         = P_Line_num(loop_index);

-- Update the update_counter

   l_count  := l_count + 1;
   -- Update the EIs
     IF g1_debug_mode  = 'Y' THEN
     	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' updateing ei ');
     END IF;
     Update PA_EXPENDITURE_ITEMS_ALL
     Set
	    invproc_rate_type	             =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_invproc_rate_type(loop_index), NULL),
	    invproc_rate_date     	     =
				DECODE(tmp_status_tab(loop_index),'N',
				--tmp_invproc_rate_date(loop_index), NULL), --Modified for Bug 3137196
				decode(tmp_invproc_rate_type(loop_index), 'User', null, tmp_invproc_rate_date(loop_index)), NULL),
	    invproc_exchange_rate	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_invproc_exchange_rate(loop_index), NULL),
	    bill_amount	     		     =
				DECODE(tmp_status_tab(loop_index),'N',NVL(bill_amount,0) +
				tmp_invproc_bill_amount(loop_index), NULL), --for bug#2251021,
	    invproc_currency_code	     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_invproc_currency_code(loop_index), NULL),
            projfunc_inv_rate_type           =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_projfunc_rate_type(loop_index), NULL),
            projfunc_inv_rate_date           =
				DECODE(tmp_status_tab(loop_index),'N',
				--tmp_projfunc_rate_date(loop_index), NULL), --Modified for Bug 3137196
				decode(tmp_projfunc_rate_type(loop_index), 'User', null, tmp_projfunc_rate_date(loop_index)), NULL),
            projfunc_inv_exchange_rate       =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_projfunc_exchange_rate(loop_index), NULL),
	    projfunc_bill_amount	     		     =
				DECODE(tmp_status_tab(loop_index),'N',NVL(projfunc_bill_amount,0) +
				tmp_projfunc_bill_amount(loop_index), NULL), --bug2251021
	    projfunc_currency_code	     		     =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_projfunc_currency_code(loop_index), NULL),
            project_inv_rate_type           =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_project_rate_type(loop_index), NULL),
            project_inv_rate_date           =
				DECODE(tmp_status_tab(loop_index),'N',
				--tmp_project_rate_date(loop_index), NULL), --Modified for Bug 3137196
				decode(tmp_project_rate_type(loop_index), 'User', null, tmp_project_rate_date(loop_index)), NULL),
            project_inv_exchange_rate       =
				DECODE(tmp_status_tab(loop_index),'N',
				tmp_project_exchange_rate(loop_index), NULL),
	    project_bill_amount	     		     =
				DECODE(tmp_status_tab(loop_index),'N',NVL(project_bill_amount,0) +
				tmp_project_bill_amount(loop_index), NULL), --bug2251021
	    inv_gen_rejection_code	     = tmp_status_tab(loop_index),
	    request_id			     = P_Request_id,
            program_id			     = l_program_id,
            program_application_id	     = l_program_application_id,
            program_update_date		     = l_program_update_date
    Where   expenditure_item_id              = P_Expenditure_item_id(loop_index);

  End Loop;

  IF g1_debug_mode  = 'Y' THEN
  	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || ' equating invproc amounts ');
  END IF;



  FOR loop_index in 1..P_No_of_rec
  LOOP
	p_invproc_invoice_amount(loop_index) := TO_CHAR(tmp_invproc_bill_amount(loop_index));

	/* Bug 2645634, 2649243 Retention amount should be calculated correctly
	               This was causing funding */

        p_invproc_bill_amount(loop_index)    := TO_CHAR(tmp_invproc_bill_amount(loop_index) *
						 (1- NVL(TO_NUMBER(l_retention_percentage),0)) );
	p_status_code(loop_index)	     := tmp_status_tab(loop_index);

  END LOOP;

-- Assign the output value
   X_Rec_upd  := l_count;
   if l_err_count = P_No_of_rec then
      x_return_status := 'ALL'; -- All records have errored out b'cos of conversion rate
   end if;

EXCEPTION
  When Others
  Then
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || 'Error in MARK_CUST_REV_DIST_LINES ' || sqlerrm);
          END IF;

          x_return_status := sqlerrm( sqlcode );
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: ' || x_return_status);
          END IF;

       --Raise;

END MARK_CUST_REV_DIST_LINES;

Function IS_AR_INSTALLED( P_Check_prod_installed  in  varchar2 ,
                          P_Check_org_installed   in  varchar2 )
return Varchar2
IS
  l_count          NUMBER;
  l_status         VARCHAR2(1);
  l_industry       VARCHAR2(100);
  l_schema         VARCHAR2(100);
  l_overrid_status VARCHAR2(1);
BEGIN

-- Call AOL API to extract installation information

   If NOT FND_INSTALLATION.GET_APP_INFO
      ( APPLICATION_SHORT_NAME      => 'AR',
        STATUS                      => l_status,
        INDUSTRY                    => l_industry,
        ORACLE_SCHEMA               => l_schema )
   Then
      Return('N');
   End If;

   l_overrid_status := l_status;

--  Bug # 956364  begin

-- Calling Client Extension driver package to get the override installation mode

     pa_ar_inst_client_extn.client_extn_driver(l_status,l_overrid_status);

-- Bug 956364 end

--

-- Return the status if only product installion info is required

  If   (P_Check_prod_installed = 'Y'
  and   P_Check_org_installed <> 'Y')
  Then
       If  l_status = 'I'
       Then
           Return('Y');
       Else
           Return('N');
       End If;
  End If;

-- Check the product installtion for the current organization setup

 If P_Check_org_installed = 'Y'
 Then

  Select count(*)
  Into   l_count
  From   AR_SYSTEM_PARAMETERS;

  If  l_count = 0
  Then
      Return('N');
  Else
      Return('Y');
  End If;

 End If;

EXCEPTION
  When Others
  Then
       Raise;

END IS_AR_INSTALLED;

-- Function               : GET_DRAFT_INVOICE_TAX_AMT
-- Usage                  : This function will return 0 if invoice is not inter
--                          faced to AR, otherwise return tax amount for that
--                          invoice.
-- Parameter              :
--       P_Trx_Id                -Customer Transaction Identifier

  Function GET_DRAFT_INVOICE_TAX_AMT( P_Trx_Id  in  NUMBER )
  return Number
  AS
     l_tax_amout   NUMBER;
  BEGIN
     Select sum(TRX_LINE.EXTENDED_AMOUNT)
     Into   l_tax_amout
     From   RA_Customer_Trx_Lines TRX_LINE
     Where  TRX_LINE.Customer_Trx_Id  = P_Trx_Id
     And    TRX_LINE.Line_Type        = 'TAX'
     And    TRX_LINE.LINK_TO_CUST_TRX_LINE_ID Is Not Null;

     Return(l_tax_amout);

  EXCEPTION
    When Others
    Then
       Raise;

  END GET_DRAFT_INVOICE_TAX_AMT;

/*Added the two parameters bill_to_customer_id and ship_to_customer_id
  for customer account relation enhancement bug no 2760630*/

/* For Intercompany Invoice Tax calculation, The following package is
   created */

  PROCEDURE GET_DEFAULT_TAX_INFO_ARR
           ( P_Project_Id                      IN   number ,
             P_Customer_Id                     IN   number ,
             P_Bill_to_site_use_id             IN   number ,
             P_Ship_to_site_use_id             IN   number ,
             P_Set_of_books_id                 IN   number ,
             P_Expenditure_item_id             IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_User_Id                         IN   NUMBER ,
             P_Request_id                      IN   NUMBER ,
             P_No_of_records                   IN   NUMBER ,
             P_Compute_flag                IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
             P_Error_Code                  IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
             X_Output_tax_code      OUT NOCOPY    PA_PLSQL_DATATYPES.Char30TabTyp,
             X_Output_tax_exempt_flag         OUT NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
             X_Output_tax_exempt_number       OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
             X_Output_exempt_reason_code      OUT NOCOPY  PA_PLSQL_DATATYPES.Char80TabTyp,
             Pbill_to_customer_id              IN   NUMBER,
             Pship_to_customer_id              IN   NUMBER)
  IS
  BEGIN

-- Process for each element of the array for which computation
-- flag is set to Y.

    FOR I IN 1..P_No_of_records
    LOOP
        If P_Compute_flag(I) = 'Y'
        Then

-- Call the tax and its attribute determination API for each element
-- of input expenditure array.

/*Added the two parameters bill_to_customer_id and ship_to_customer_id
  for customer account relation enhancement bug no 2760630*/

           GET_DEFAULT_TAX_INFO
              ( P_Project_Id    => P_Project_Id,
                P_Draft_Inv_Num => NULL,
                P_Customer_Id   => P_Customer_Id,
                P_Bill_to_site_use_id => P_Bill_to_site_use_id,
                P_Ship_to_site_use_id => P_Ship_to_site_use_id,
                P_Sets_of_books_id    => P_Set_of_books_id,
                P_Expenditure_item_id => P_Expenditure_item_id(I),
                P_User_Id             => P_User_Id,
                P_Request_id          => P_Request_id,
--                X_Output_vat_tax_id   => X_Output_vat_tax_id(I), --commented by hsiu
                X_output_tax_code        => X_output_tax_code(I),
                X_Output_tax_exempt_flag => X_Output_tax_exempt_flag(I),
                X_Output_tax_exempt_number => X_Output_tax_exempt_number(I),
                X_Output_exempt_reason_code=> X_Output_exempt_reason_code(I),
                Pbill_to_customer_id       => Pbill_to_customer_id,
                Pship_to_customer_id       => Pship_to_customer_id);

-- If Tax API returns error, set the output error code and set computation
-- flag to 'N'
           If pa_tax_client_extn_drv.G_error_Code Is not NULL
           Then
              P_Error_Code(I)  := pa_tax_client_extn_drv.G_error_Code;
              P_Compute_flag(I):= 'N';
           End if;
        End if;
    End loop;

  Exception

    When Others
    Then
         Raise;

  END GET_DEFAULT_TAX_INFO_ARR;

  FUNCTION TAXID_2_CODE_CONV (p_org_id in number,
                              p_tax_id in number)
  return varchar2 is

    l_tax_code varchar2(50);

  begin

    select rtrim(tax_classification_code)
    into l_tax_code
    from zx_id_tcc_mapping_all
    where tax_rate_code_id = p_tax_id
    and org_id = p_org_id
    and tax_class = 'OUTPUT'; -- added for bug 5061887

    return l_tax_code;

  exception

    when others then
         l_tax_code := NULL;
         return l_tax_code;


  end TAXID_2_CODE_CONV;

  procedure  get_legal_entity_id (p_customer_id  IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_transaction_type_id IN NUMBER,
                                  p_batch_source_id   IN NUMBER,
                                  x_legal_entity_id OUT NOCOPY NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2)
  is


      l_msg_data varchar2(250);
      l_return_status varchar2(30);
      l_otoc_le_info xle_businessinfo_grp.otoc_le_rec;

  begin

      IF g1_debug_mode  = 'Y' THEN

         PA_MCB_INVOICE_PKG.log_message('GET_DEFAULT_TAX_INFO: in get_legal_entity_id' );
         PA_MCB_INVOICE_PKG.log_message('p_customer_id          : ' || P_customer_id );
         PA_MCB_INVOICE_PKG.log_message('p_org_id  : ' || p_org_id );
         PA_MCB_INVOICE_PKG.log_message('p_transaction_type_id  : ' || P_transaction_type_id );
         PA_MCB_INVOICE_PKG.log_message('p_batch_source_id  : ' || P_batch_source_id );

         PA_MCB_INVOICE_PKG.log_message('calling XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info ');
      END IF;

      XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info(
                x_return_status        => l_return_status,
                x_msg_data             => l_msg_data,
                P_customer_type        => 'BILL_TO',
                P_customer_id          => p_customer_id,
                P_transaction_type_id  => p_transaction_type_id,
                P_batch_source_id      => p_batch_source_id,
                P_operating_unit_id    => p_org_id,
                x_otoc_Le_info         => l_otoc_le_info) ;

      IF g1_debug_mode  = 'Y' THEN

         PA_MCB_INVOICE_PKG.log_message('after calling XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info ');
         PA_MCB_INVOICE_PKG.log_message('legal_entity_id  : ' || l_otoc_le_info.legal_entity_id );
         PA_MCB_INVOICE_PKG.log_message('return status  : ' || l_return_status);

         PA_MCB_INVOICE_PKG.log_message('msg data  : ' || l_msg_data);

      END IF;

      x_legal_entity_id  := l_otoc_le_info.legal_entity_id;
      x_return_status := l_return_status;


  end get_legal_entity_id;

  procedure get_btch_src_trans_type ( p_project_id IN NUMBER,
                                     p_draft_invoice_num IN NUMBER,
                                     p_draft_inv_num_credited IN NUMBER,
                                     x_transaction_type_id out NOCOPY number,
                                     x_batch_source_id out NOCOPY number,
                                     x_return_status OUT NOCOPY varchar2) is

       l_business_grp_id     number;
       l_carry_out_org_id    number;
       l_org_struct_ver_id   number;
       l_basic_language_code varchar2(4);
       l_p_trx_type_id       number;
       l_cm_trx_type_id      number;
       l_error_status        number;
       l_error_message       varchar2(250);
       l_p_trx_type          varchar2(30);
       l_cm_trx_type         varchar2(30);
       l_batch_source_id     number;
       l_draft_inv_num_credited number;
       l_invoice_date        date;  /* added for bug 9246335 */


  begin

       IF g1_debug_mode  = 'Y' THEN

         PA_MCB_INVOICE_PKG.log_message('in get_btch_src_trans_type');
         PA_MCB_INVOICE_PKG.log_message('project_id  : ' || p_project_id);
         PA_MCB_INVOICE_PKG.log_message('draft_invoice_num :' || p_draft_invoice_num );

       END IF;

       SELECT business_group_id,
              proj_org_structure_version_id,
              invoice_batch_source_id
       INTO   l_business_grp_id,
              l_org_struct_ver_id,
              l_batch_source_id
       FROM pa_implementations;


       IF g1_debug_mode  = 'Y' THEN

         PA_MCB_INVOICE_PKG.log_message('business group id  : ' || l_business_grp_id);
         PA_MCB_INVOICE_PKG.log_message('proj org str vers id :' || l_org_struct_ver_id );
         PA_MCB_INVOICE_PKG.log_message('inv btch src id :' || l_batch_source_id );

       END IF;

       SELECT PROJ.Carrying_Out_Organization_ID
       INTO l_carry_out_org_id
       FROM pa_projects proj
       WHERE project_id = p_project_id;


       SELECT language_code
       INTO   l_basic_language_code
       FROM   fnd_languages
       WHERE  installed_flag = 'B';

	   /*Added exception handling block for the below select into query for bug 9322678*/

       BEGIN
	   /* added for bug 9246335 */
		   SELECT invoice_date
		   INTO l_invoice_date
		   FROM pa_draft_invoices
		   WHERE project_id = p_project_id
		   and draft_invoice_num = p_draft_invoice_num;
	   /* end of code for bug 9246335 */
       EXCEPTION
		   WHEN NO_DATA_FOUND THEN
              l_invoice_date := pa_billing.GetInvoiceDate;
              IF g1_debug_mode  = 'Y' THEN
                 PA_MCB_INVOICE_PKG.log_message('l_invoice_date:=' || l_invoice_date);
              END IF;
       END ;

       IF g1_debug_mode  = 'Y' THEN

         PA_MCB_INVOICE_PKG.log_message('carrying out org id  : ' || l_carry_out_org_id);
         PA_MCB_INVOICE_PKG.log_message('basic lang code  :' || l_basic_language_code );
         PA_MCB_INVOICE_PKG.log_message('calling get_trx_crmemo types');

       END IF;

       pa_invoice_xfer.get_trx_crmemo_types(
                   P_business_group_id          => l_business_grp_id  ,
                   P_carrying_out_org_id        => l_carry_out_org_id  ,
                   P_proj_org_struct_version_id => l_org_struct_ver_id  ,
                   p_basic_language             => l_basic_language_code  ,
                   P_trans_type                 => l_p_trx_type ,
                   p_trans_date                 => l_invoice_date,     /* added for bug 9246335 */
                   P_crmo_trx_type              => l_cm_trx_type  ,
                   P_error_status               => l_error_status  ,
                   P_error_message              => l_error_message);

       IF g1_debug_mode  = 'Y' THEN

         PA_MCB_INVOICE_PKG.log_message('trans type : ' || l_p_trx_type);
         PA_MCB_INVOICE_PKG.log_message('crmo trx type:' || l_cm_trx_type );

       END IF;

       IF nvl(p_draft_inv_num_credited,0) = 0 THEN

          x_transaction_type_id  := to_number(l_p_trx_type);

       ELSE

          x_transaction_type_id  := to_number(l_cm_trx_type);

       END IF;
       x_batch_source_id :=  l_batch_source_id;

  end get_btch_src_trans_type;

END PA_OUTPUT_TAX;

/
