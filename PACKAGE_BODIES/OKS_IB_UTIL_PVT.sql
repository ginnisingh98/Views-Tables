--------------------------------------------------------
--  DDL for Package Body OKS_IB_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IB_UTIL_PVT" As
/* $Header: OKSRIBUB.pls 120.46.12000000.2 2007/02/22 21:48:25 dneetha ship $ */



  -- Constants used for Message Logging
  G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_CURRENT    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_MODULE_CURRENT   CONSTANT VARCHAR2(255) := 'oks.plsql.oks_ib_util_pvt';


 FUNCTION party_contact_info(
    p_object1_code  IN VARCHAR2,
    p_object1_id1   IN VARCHAR2,
    p_object1_id2   IN VARCHAR2,
    p_org_id     IN NUMBER,
    p_info_req   IN VARCHAR2 --possible values are 'NAME ,PHONE, EMAIL'
  )
  RETURN VARCHAR2
  IS


CURSOR party_contact_kadmin IS
SELECT c.last_name || ' ' || c.first_name NAME,
       c.phone,
       c.email_address email
  FROM jtf_rs_resource_extns rsc,
       ap_supplier_sites_all pvs,
       hz_party_sites hps,
       hz_locations hl,
       po_vendor_contacts c
 WHERE rsc.CATEGORY = 'SUPPLIER_CONTACT'
   AND c.vendor_contact_id = rsc.source_id
   AND pvs.vendor_site_id = c.vendor_site_id
   AND pvs.org_id = p_org_id
   AND rsc.resource_id = TO_NUMBER (p_object1_id1)
   AND '#' = p_object1_id2
   AND pvs.location_id = hl.location_id(+)
   AND pvs.party_site_id = hps.party_site_id(+)
UNION ALL
SELECT emp.full_name NAME,
       emp.work_telephone phone,
       emp.email_address email
  FROM jtf_rs_resource_extns rsc,
       per_all_people_f emp
 WHERE rsc.CATEGORY = 'EMPLOYEE'
   AND emp.person_id = rsc.source_id
   AND rsc.resource_id = TO_NUMBER (p_object1_id1)
   AND '#' = p_object1_id2
UNION ALL
SELECT rsctl.resource_name NAME,
       NULL phone,
       srp.email_address email
  FROM jtf_rs_resource_extns rsc,
       jtf_rs_resource_extns_tl rsctl, --Bug Fix #5456468 Dneetha
       jtf_rs_salesreps srp
 WHERE rsc.CATEGORY = 'OTHER'
   AND srp.resource_id = rsc.resource_id
   AND srp.org_id = p_org_id
   AND rsc.resource_id = TO_NUMBER (p_object1_id1)
   AND '#' = p_object1_id2
   AND rsctl.RESOURCE_ID = rsc.RESOURCE_ID  -- Bug Fix #5456468 Dneetha
   AND rsctl.LANGUAGE = USERENV('LANG')
   AND rsctl.CATEGORY = rsc.CATEGORY


UNION ALL
SELECT party.party_name NAME,
       party.primary_phone_area_code || '-' || party.primary_phone_number
                                                                        phone,
       party.email_address email
  FROM jtf_rs_resource_extns rsc,
       hz_parties party
 WHERE rsc.CATEGORY IN ('PARTY', 'PARTNER')
   AND party.party_id = rsc.source_id
   AND rsc.resource_id = TO_NUMBER (p_object1_id1)
   AND '#' = p_object1_id2;



/* Share memory issue
    CURSOR party_contact_kadmin IS
    SELECT   C.LAST_NAME ||' '||c.first_name name, c.phone, c.email_address email
    FROM
             JTF_RS_RESOURCE_EXTNS RSC ,
             PO_VENDOR_SITES_ALL S ,
             PO_VENDOR_CONTACTS C
    WHERE
             RSC.CATEGORY = 'SUPPLIER_CONTACT'
             AND C.VENDOR_CONTACT_ID = RSC.SOURCE_ID
             AND S.VENDOR_SITE_ID = C.VENDOR_SITE_ID
             AND S.ORG_ID = p_org_id
             AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2
    UNION ALL
    SELECT    EMP.FULL_NAME name , emp.work_telephone phone ,emp.email_address email
    FROM JTF_RS_RESOURCE_EXTNS RSC ,
          PER_ALL_PEOPLE_F EMP
    WHERE
             RSC.CATEGORY = 'EMPLOYEE'
             AND EMP.PERSON_ID = RSC.SOURCE_ID
             AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2
      UNION ALL
      SELECT
             SRP.NAME name, null phone ,srp.email_address email
      FROM
             JTF_RS_RESOURCE_EXTNS RSC ,
             JTF_RS_SALESREPS SRP
      WHERE
             RSC.CATEGORY = 'OTHER'
             AND SRP.RESOURCE_ID = RSC.RESOURCE_ID
             AND SRP.ORG_ID = p_org_id
             AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2
             UNION ALL
       SELECT party.party_name name, party.primary_phone_area_code ||'-'||party.primary_phone_number phone ,party.email_address email
       FROM JTF_RS_RESOURCE_EXTNS RSC ,HZ_PARTIES PARTY
       WHERE RSC.CATEGORY IN ( 'PARTY', 'PARTNER')
       AND PARTY.PARTY_ID = RSC.SOURCE_ID
       AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2 ;
*/

    CURSOR party_contact_salesrep IS
     SELECT
             RSCTL.Resource_name name, null phone ,srp.email_address email
      FROM
             JTF_RS_RESOURCE_EXTNS RSC ,
             JTF_RS_RESOURCE_EXTNS_tl RSCTL ,-- Bug Fix #5456468 dneetha
             JTF_RS_SALESREPS SRP
      WHERE
             RSC.CATEGORY IN ('EMPLOYEE','OTHER','PARTY','PARTNER','SUPPLIER_CONTACT')
             AND SRP.RESOURCE_ID = RSC.RESOURCE_ID
             AND SRP.ORG_ID = p_org_id
             AND SRP.SALESREP_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2
             AND RSCTL.RESOURCE_ID = RSC.RESOURCE_ID  -- Bug Fix #5456468 dneetha
             AND RSCTL.LANGUAGE = USERENV('LANG')
             AND RSCTL.CATEGORY = RSC.CATEGORY;






    l_party_contact_kadmin_rec  party_contact_kadmin%rowtype;
    l_party_contact_salesrep_rec party_contact_salesrep%rowtype;
    l_party_info VARCHAR2(300);

    BEGIN
      IF p_object1_code = 'OKX_RESOURCE'
      THEN
        OPEN  party_contact_kadmin;
        FETCH party_contact_kadmin
        INTO
          l_party_contact_kadmin_rec;
        CLOSE  party_contact_kadmin;
        If  p_info_req = 'NAME' THEN
            l_party_info:= l_party_contact_kadmin_rec.name;
        Elsif p_info_req = 'EMAIL' THEN
            l_party_info:= l_party_contact_kadmin_rec.email;
        Elsif p_info_req = 'PHONE' THEN
            l_party_info:= l_party_contact_kadmin_rec.phone;
        End If;
      ELSIF p_object1_code = 'OKX_SALEPERS'
       THEN
        OPEN  party_contact_salesrep;
        FETCH party_contact_salesrep
        INTO
          l_party_contact_salesrep_rec;
        CLOSE  party_contact_salesrep;
        If  p_info_req = 'NAME' THEN
            l_party_info:= l_party_contact_salesrep_rec.name;
        Elsif p_info_req = 'EMAIL' THEN
            l_party_info:= l_party_contact_salesrep_rec.email;
        Elsif p_info_req = 'PHONE' THEN
            l_party_info:= l_party_contact_salesrep_rec.phone;
        End If;
      END IF;
    RETURN l_party_info;
  END party_contact_info;

FUNCTION check_partial_flag (p_id NUMBER, p_flag VARCHAR2)
   RETURN VARCHAR2
IS
   CURSOR get_hdr_temp_count
   IS
      SELECT COUNT (*)
        FROM Oks_Instance_k_dtls_temp
       WHERE contract_id = p_id;

   CURSOR get_line_temp_count
   IS
      SELECT COUNT (*)
        FROM Oks_Instance_k_dtls_temp
       WHERE topline_id = p_id;

   CURSOR get_hdr_count
   IS
      SELECT COUNT (*)
        FROM okc_k_lines_b
       WHERE dnz_chr_id = p_id
       AND  lse_id IN (9, 18, 25);

   CURSOR get_line_count
   IS
      SELECT COUNT (*)
        FROM okc_k_lines_b
       WHERE cle_id = p_id AND lse_id IN (9, 18, 25);
       l_temp_count NUMBER := 0;
       l_count NUMBER := 0;
BEGIN
   IF p_flag = 'H'
   THEN
      OPEN get_hdr_temp_count;
      FETCH get_hdr_temp_count INTO l_temp_count;
      CLOSE get_hdr_temp_count;

      OPEN get_hdr_count;
      FETCH get_hdr_count INTO l_count;
      CLOSE get_hdr_count;

      IF l_temp_count < l_count
      THEN
         RETURN ('Y');
      ELSE
         RETURN ('N');
      END IF;
   ELSE
      OPEN get_line_temp_count;
      FETCH get_line_temp_count INTO l_temp_count;
      CLOSE get_line_temp_count;

      OPEN get_line_count;
      FETCH get_line_count INTO l_count;
      CLOSE get_line_count;

      IF l_temp_count < l_count
      THEN
         RETURN ('Y');
      ELSE
         RETURN ('N');
      END IF;
   END IF;
END;


Procedure Get_prod_name(P_line_id  Number, x_prod_name Out NoCopy Varchar2, X_system_name Out NoCopy Varchar2)
Is


Cursor l_lse_csr is
Select lse_id
From   OKc_k_lines_b
Where   id = p_line_id;

Cursor l_prodSys_name_csr
Is


Select mtl.concatenated_segments, sys.name
From   mtl_system_items_kfv mtl, okc_k_items_v itm
       ,csi_item_instances csi, csi_systems_tl sys
where itm.cle_id = P_line_id
And   itm.jtot_object1_code = 'OKX_CUSTPROD'
And   csi.instance_id = itm.object1_id1
And csi.inventory_item_id = mtl.inventory_item_id
And sys.system_id(+) = csi.system_id
And rownum < 2
;



Cursor l_counter_csr Is
Select mtl.concatenated_segments
From   mtl_system_items_kfv mtl, csi_counter_associations ctrAsc
       , okc_k_items_v itm
       ,csi_item_instances csi
Where itm.cle_id = P_line_id
And   ctrAsc.counter_id = itm.object1_id1
And   csi.instance_id = ctrAsc.source_object_id
And   mtl.inventory_item_id = csi.inventory_item_id
And   rownum < 2
;

l_prod_name Varchar2(40);
l_System_name Varchar2(40);

l_lse_id    Number;

begin
       Open l_lse_csr;
       Fetch l_lse_csr into l_lse_id;
       Close l_lse_csr;

       If l_lse_id = 13 Then
           Open l_counter_csr;
           Fetch l_counter_csr into l_prod_name;
           Close l_counter_csr;
       Else
           Open l_prodSys_name_csr;
           Fetch l_prodSys_name_csr into l_prod_name, l_system_name;
           Close l_prodSys_name_csr;
       End If;

       x_prod_name := l_prod_name;
       x_system_name := l_system_name;

End;



/* ***********************************************
 *  Get the bill Contact name for the Contract Id. This function
 *  is called in ContractsHdrMasterExpVORowImpl and
 *  ContractHdrTerminateExpVORowImpl
*/

Function get_BillContact_name(P_Contract_Id Number) return Varchar2 Is

Cursor l_bill_contact_csr Is
 Select Decode(SUBSTR (hz.person_last_name || ','|| hz.person_first_name, 1,255),',',null,SUBSTR (hz.person_last_name || ', '|| hz.person_first_name, 1,255)) Billing_contact
     From  hz_parties hz
           , okc_contacts oc2
           ,hz_relationships hr
     Where oc2.jtot_object1_code = 'OKX_PCONTACT'
     And   oc2.cro_code = 'BILLING'
     AND   oc2.dnz_chr_id = p_contract_id
     AND   hr.party_id = oc2.object1_id1
     AND   hz.party_id = hr.subject_id;

     l_bill_contact  Varchar2(240);

Begin
     For l_contact_rec in l_bill_contact_csr
     Loop
           l_bill_contact := l_contact_rec.Billing_contact;
           Exit when l_bill_contact is not null;
      End Loop;



     return(l_bill_contact);

End;

/* ***********************************************
 *  Get the Salesperson name for the Contract Id. This function
 *  is called in ContractsHdrMasterExpVORowImpl and
 *  ContractHdrTerminateExpVORowImpl
*/
Function get_salesrep_name(P_Contract_Id Number) return Varchar2 Is

Cursor l_salesrep_csr Is
Select  v.resource_name sales_person
From    jtf_rs_salesreps jtf
         , jtf_rs_resource_extns_vl v
         , okc_contacts oc1
         ,Okc_k_headers_all_b kh

Where      oc1.dnz_chr_id = P_contract_id
And        Kh.id = oc1.dnz_chr_id
And        Kh.authoring_org_id = jtf.org_id
AND        oc1.jtot_object1_code = 'OKX_SALEPERS'
AND        oc1.object1_id1 = jtf.salesrep_id
And        v.resource_id = jtf.resource_id;



l_salesperson  varchar2(240);
Begin

       For l_salesperson_rec in l_salesrep_csr
       Loop

               l_salesperson := l_salesperson_rec.sales_person;
               exit when l_salesperson is not null;

       End Loop;

       Return (l_salesperson);


End;



FUNCTION round_currency_amt ( P_amount  IN NUMBER ,
                         P_currency_code IN Varchar2 ) RETURN NUMBER
IS

Cursor fnd_cur IS
         SELECT Minimum_Accountable_Unit,
                Precision,
                Extended_Precision
         FROM FND_CURRENCIES
         WHERE Currency_Code = P_currency_code;

l_mau FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
l_sp  FND_CURRENCIES.PRECISION%TYPE;
l_ep  FND_CURRENCIES.EXTENDED_PRECISION%TYPE;

BEGIN
   open fnd_cur;
   fetch fnd_cur into l_mau,l_sp,l_ep;
   close fnd_cur;

   IF l_mau IS NOT NULL THEN

       IF l_mau < 0.00001 THEN
         RETURN( round(P_Amount, 5));
       ELSE
         RETURN( round(P_Amount/l_mau) * l_mau );
       END IF;

   ELSIF l_sp IS NOT NULL THEN

       IF l_sp > 5 THEN
         RETURN( round(P_Amount, 5));
       ELSE
         RETURN( round(P_Amount, l_sp));
       END IF;

   ELSE

       RETURN( round(P_Amount, 5));

   END IF;

END round_currency_amt;

/* ***********************************************
 *  Get the transferred amount to be diaplayed
 * in the impacted contracts region for transfer batch
**************************************************/


FUNCTION get_transferred_amount (
   p_line_id         IN   NUMBER,
   p_transfer_date   IN   DATE
)
   RETURN NUMBER
IS
   CURSOR l_covln_detls
   IS
      SELECT Kl.start_date,
             Kl.end_date,
             nvl(Kl.price_negotiated,0),
             Kl.currency_code,
             Ks.price_uom,
             Kh.period_start,
             Kh.period_type

      FROM okc_k_lines_b Kl
           ,Oks_k_headers_b  Kh
           ,oks_k_lines_b Ks

      WHERE Kl.ID = p_line_id
      And   Ks.cle_id = Kl.Id
      And   Kh.chr_id = kl.dnz_chr_id


      ;

      l_start_date      Date;
      l_end_date        Date;
      l_amount          Number;
      l_currency        Varchar2(30);
      l_trfdt           Date;
      l_newamt          Number;
      l_price_uom       Varchar2(10);

      l_period_start    Varchar2(30);
      l_period_type     Varchar2(10);
      l_duration_xfer  Number;
      l_duration_total  Number;


BEGIN

       Open l_covln_detls;
       Fetch l_covln_detls into l_start_date, l_end_date, l_amount, l_currency,l_price_uom, l_period_start, l_period_type;
       Close l_covln_detls;

       If trunc(p_transfer_date) > trunc(l_end_date) Then

             l_newamt := 0;
       Else

             If trunc(l_start_date) > trunc(P_transfer_date) Then
                 l_trfdt := l_start_date;
             Else
                 l_trfdt := p_transfer_date;
             End If;
             If l_price_uom is Null Then
                     l_price_uom := Oks_misc_util_web.duration_unit
                          (
                            trunc(l_start_Date),
                            trunc(l_end_date));
             End If;

             l_duration_xfer :=  OKS_TIME_MEASURES_PUB.get_quantity
                                (trunc(l_trfdt) ,
                                 trunc(l_end_date),
                                l_price_uom,
                                 l_period_type ,
                                 l_period_Start );



             l_duration_total  := OKS_TIME_MEASURES_PUB.get_quantity
                                (trunc(l_Start_date) ,
                                 trunc(l_end_date),
                                 l_price_uom,
                                 l_period_type ,
                                 l_period_Start );


             l_newamt := oks_extwar_util_pvt.round_currency_amt(l_amount * l_duration_xfer/l_duration_total,l_currency);

     End if;
     return (nvl(l_newamt ,0));







END;

/* ***********************************************
 *  Get the actual transferred amount to be diaplayed
 * in the impacted contracts region for completed transfer batch
**************************************************/

Function Get_actual_transferamount(p_line_id Number, P_batch_id Number, P_line_type Varchar2) return Number Is

Cursor l_amt_csr Is
Select  nvl(instance_amt_new,0)
From     Oks_instance_history ih
       , Oks_inst_hist_details id
Where    ih.batch_id = p_batch_id
And      id.ins_id = ih.id
And      id.old_subline_id = p_line_id
And      id.old_subline_id <> id.new_subline_id;

Cursor l_line_amt_csr Is
Select  nvl(sum(instance_amt_new),0)
From     Oks_instance_history ih
       , Oks_inst_hist_details id
Where    ih.batch_id = p_batch_id
And      id.ins_id = ih.id
And      id.old_service_line_id = p_line_id
And      id.old_service_line_id <> id.new_service_line_id ;


Cursor l_Hdr_amt_csr Is
Select  sum(instance_amt_new)
From    Oks_instance_history ih
       , Oks_inst_hist_details id
Where    ih.batch_id = p_batch_id
And      id.ins_id = ih.id
And      id.old_contract_id = p_line_id
And      id.old_contract_id <> id.new_contract_id ;



l_transfer_amount  Number;
Begin
   If P_line_type = 'SL' Then
       Open l_amt_csr;
       Fetch l_amt_csr into l_transfer_amount;
       Close l_amt_csr;

   Elsif P_line_type = 'TL' Then

       Open l_line_amt_csr;
       Fetch l_line_amt_csr into l_transfer_amount;
       Close l_line_amt_csr;


   Else
       Open l_hdr_amt_csr;
       Fetch l_hdr_amt_csr into l_transfer_amount;
       Close l_hdr_amt_csr;

   End If;
       l_transfer_amount := nvl(l_transfer_amount,0);


       Return (l_transfer_amount);

End;


/* ***********************************************
 *  Get the actual credit amount to be diaplayed
 * in the impacted contracts region for completed
 * terminate/transfer batch
**************************************************/
Function Get_actual_creditamount(p_line_id Number, P_batch_id Number, P_line_type Varchar2) return Number Is
Cursor l_credit_csr Is
Select NVL (SUM (bill.amount), 0)
From    Oks_bill_sub_lines bill
      , Oks_instance_history ih
      , Oks_inst_hist_details id
      , Oks_bill_cont_lines bcl
Where  bill.cle_id = id.old_subline_id
And    ih.batch_id = p_batch_id
And    id.ins_id = ih.id
And    id.old_subline_id = p_line_id
And      id.old_subline_id = id.new_subline_id
And    bill.bcl_id = bcl.id
And    bcl.bill_action = 'TR'
And    nvl(bcl.btn_id,0) <> -44;

Cursor l_tl_credit_csr Is

Select  nvl(sum(bill.amount),0)
From     Oks_bill_sub_lines bill
       , Oks_instance_history ih
       , Oks_inst_hist_details id
       , Okc_k_lines_b Kl
      , Oks_bill_cont_lines bcl
Where    ih.batch_id = p_batch_id
And      id.ins_id = ih.id
And      bill.cle_id = Kl.Id
And      Kl.cle_Id = id.old_service_line_id
And      Kl.id = id.old_subline_id
And      id.old_subline_id = id.new_subline_id
And      id.old_service_line_id = p_line_id
And    bill.bcl_id = bcl.id
And    bcl.bill_action = 'TR'
And    nvl(bcl.btn_id,0) <> -44;

Cursor l_Hdr_credit_csr Is
Select  nvl(sum(bill.amount),0)
From     Okc_k_lines_b kl
       , Oks_bill_sub_lines bill
       , Oks_instance_history ih
       , Oks_inst_hist_details id
      , Oks_bill_cont_lines bcl
Where    ih.batch_id = p_batch_id
And      id.ins_id = ih.id
And      bill.cle_id = kl.Id
And      Kl.dnz_chr_id = id.old_contract_id
And      Kl.id = id.old_subline_id
And      id.old_subline_id = id.new_subline_id
And      id.old_contract_id = p_line_id
And    bill.bcl_id = bcl.id
And    bcl.bill_action = 'TR'
And    nvl(bcl.btn_id,0) <> -44;




l_credit_amount  Number;

Begin

    If P_line_type = 'SL' Then
       Open l_Credit_csr;
       Fetch l_credit_csr into l_credit_amount;
       Close l_credit_csr;

       return (abs(l_credit_amount));
    Elsif P_line_type = 'TL' Then
       Open l_Tl_Credit_csr;
       Fetch l_Tl_Credit_csr into l_credit_amount;
       Close l_Tl_Credit_csr;

       return (abs(l_credit_amount));



    Else
       Open l_hdr_Credit_csr;
       Fetch l_hdr_Credit_csr into l_credit_amount;
       Close l_hdr_Credit_csr;

       return (abs(l_credit_amount));


    End If;

End;


/* ***********************************************
 *  Get the actual billed amount to be displayed
 * in the impacted contracts region for completed
 * terminate/transfer batch
**************************************************/
Function Get_actual_billedamount(p_line_id Number, P_batch_id Number, P_line_type Varchar2) return Number Is

Cursor l_billed_csr Is
Select NVL (SUM (bill.amount), 0)
From    Oks_bill_sub_lines bill
      , Oks_instance_history ih
      , Oks_inst_hist_details id
      , Oks_bill_cont_lines bcl
Where  bill.cle_id = id.old_subline_id
And    ih.batch_id = p_batch_id
And    id.ins_id = ih.id
And    id.old_subline_id = p_line_id
And    bill.bcl_id = bcl.id
And    bcl.bill_action = 'RI';

Cursor l_tl_billed_csr Is

Select  nvl(sum(bill.amount),0)
From     Oks_bill_sub_lines bill
       , Oks_instance_history ih
       , Oks_inst_hist_details id
       , Okc_k_lines_b Kl
      , Oks_bill_cont_lines bcl
Where    ih.batch_id = p_batch_id
And      id.ins_id = ih.id
And      bill.cle_id = Kl.Id
And      Kl.cle_Id = id.old_service_line_id
And      Kl.id = id.old_subline_id
And      id.old_service_line_id = p_line_id
And    bill.bcl_id = bcl.id
And    bcl.bill_action = 'RI';

Cursor l_Hdr_billed_csr Is
Select  nvl(sum(bill.amount),0)
From     Okc_k_lines_b kl
       , Oks_bill_sub_lines bill
       , Oks_instance_history ih
       , Oks_inst_hist_details id
      , Oks_bill_cont_lines bcl
Where    ih.batch_id = p_batch_id
And      id.ins_id = ih.id
And      bill.cle_id = kl.Id
And      Kl.dnz_chr_id = id.old_contract_id
And      Kl.id = id.old_subline_id
And      id.old_contract_id = p_line_id
And    bill.bcl_id = bcl.id
And    bcl.bill_action = 'RI';


l_billed_amount  Number;

Begin

    If P_line_type = 'SL' Then
       Open l_billed_csr;
       Fetch l_billed_csr into l_billed_amount;
       Close l_billed_csr;

       return (l_billed_amount);
    Elsif P_line_type = 'TL' Then
       Open l_Tl_billed_csr;
       Fetch l_Tl_billed_csr into l_billed_amount;
       Close l_Tl_billed_csr;

       return (l_billed_amount);



    Else
       Open l_hdr_billed_csr;
       Fetch l_hdr_billed_csr into l_billed_amount;
       Close l_hdr_billed_csr;

       return (l_billed_amount);


    End If;

End;

/* ***********************************************
 *  Get the billed amount to be displayed
 * in the impacted contracts region for transfer/terminate
 * batch
**************************************************/
FUNCTION get_billed_amount (
   p_line_id      IN   NUMBER

)
   RETURN NUMBER
IS
   CURSOR l_billed_amount_csr (p_cle_id NUMBER)
   IS
      SELECT NVL (SUM (amount), 0)
        FROM oks_bill_sub_lines_v
       WHERE cle_id = p_cle_id;

   l_billed_amt   NUMBER;

BEGIN
   OPEN l_billed_amount_csr (p_line_id);
   FETCH l_billed_amount_csr INTO l_billed_amt;
   CLOSE l_billed_amount_csr;
   RETURN( l_billed_amt );
END;



Function get_terminate_amount(P_line_id Number, p_termination_date date)
return Number is

l_amount  Number;
l_return_status Varchar2(1);
Cursor l_chr_csr Is
Select authoring_org_id,
       inv_organization_id
From   okc_k_headers_all_b kh
       , okc_k_lines_b kl
Where  kl.id = p_line_id
And    kh.id = kl.dnz_chr_id;

l_org_id Number;
l_inv_org_id Number;

Begin

        Open l_chr_csr;
        Fetch l_chr_csr into l_org_id, l_inv_org_id;
        Close l_chr_csr;
        okc_context.set_okc_org_context (l_org_id, l_inv_org_id);

        OKS_BILL_REC_PUB.pre_terminate_amount
        (
          p_id                           => P_line_id,
          p_terminate_date               => trunc(P_termination_date),
          p_flag                         => 3,
          X_Amount                       => l_amount,
          X_return_status               => l_return_status
         );
l_amount := nvl(l_amount,0);
         return (l_amount);

End;
/* ***********************************************
 *  Procedure to check if impacted COntracts belong
 *  to multiple operating Units
**************************************************/

Procedure CheckMultipleOU(P_Batch_ID Number, p_new_account_id Number, x_party_id Out NOCOPY Number, x_org_id Out NOCOPY Number) Is



Cursor get_ou_csr Is
Select distinct(okc.authoring_org_id) org_id
From Okc_k_headers_all_b okc,  Oks_Instance_k_dtls_temp tmp
where tmp.Contract_id = okc.Id
And   tmp.Parent_id = p_batch_Id;

 Cursor l_party_csr Is
 Select party_id
 From   HZ_CUST_ACCOUNTS CA
 Where  CA.Cust_account_id = p_new_account_Id;
i  Number;
l_org_id number;
l_party_id number;
Begin

    Open l_party_csr;
    Fetch l_party_csr into l_party_id;
    Close l_party_csr;
    X_party_Id := l_party_id;



     i := 0;
     For ou_rec in get_ou_csr
     Loop

          l_org_id := ou_rec.org_id;
          i:= i +1 ;
          If i > 1 Then

             l_org_id := -1;
             exit;
          End If;
     End Loop;

     If i = 0 Then

         l_org_id := 0;
     End if;

     x_org_id := l_org_id;


End;


Function Credit_option return Varchar2
Is

 Cursor KDefld_Global_CreditOption
 Is
  Select Credit_amount
  From   OKS_K_DEFAULTS
  Where  cdt_type = 'MDT'
  AND    segment_id1 IS NULL
  AND    segment_id2 IS NULL
  AND    jtot_object_code IS NULL;
  l_credit_amount Varchar2(30);

Begin
    l_credit_amount := null;

    Open KDefld_Global_CreditOption;
    Fetch KDefld_Global_CreditOption into l_credit_amount;
    Close KDefld_Global_CreditOption;



    If l_credit_amount Is null Then

          If Nvl(fnd_profile.value('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT'),'YES') = 'YES' Then
            l_credit_amount := 'CALCULATED';
          Else
            l_credit_amount := 'NONE';
          End If;


    End If;

      return (l_credit_amount);
End;





/* ***********************************************
 *  Procudure to validate the bill to and ship to
 * details passed by IB in Contract Options page.
 * Validates if the bill to and ship to belong to the OU
**************************************************/
Procedure GetBillToShipTo(P_New_account_id Number,
P_BillTo_account_Id Number default Null,
P_BillTo_Address_Id Number default Null,
P_ShipTo_account_Id Number default Null,
P_ShipTo_Address_Id Number default Null,
P_Operating_unit Number,
X_BillTo_account_Number Out NOCOPY VARCHAR2,
X_BillTo_account_Id Out NOCOPY Number,
X_BillTo_Party Out NOCOPY Varchar2,
X_BillTo_PartyId Out NOCOPY Number,
X_BillTo_Address_Id Out NOCOPY Number,
X_BillTo_Address Out NOCOPY Varchar2,
X_ShipTo_account_Number Out NOCOPY VARCHAR2,
X_ShipTo_account_Id Out NOCOPY Number,
X_ShipTo_Party Out NOCOPY Varchar2,
X_ShipTo_PartyId Out NOCOPY Number,
X_ShipTo_Address_Id Out NOCOPY Number,
X_ShipTo_Address Out NOCOPY Varchar2,
X_Contract_status_Code Out NOCOPY Varchar2,
X_Contract_status Out NOCOPY Varchar2,
X_Party_ID OUT NOCOPY Number,
X_Credit_option OUT NOCOPY Varchar2,
P_Transaction_date Date default sysdate
) Is

Cursor Check_Acct_Csr( P_Account_id Number, p_party_id number) Is
SELECT  CA1.Account_number AccountNumber
      , CA1.CUST_ACCOUNT_ID AccountId,
        Party.party_name PartyName
      , Party.party_id PartyId
From    HZ_CUST_ACCOUNTS CA1
      , HZ_PARTIES party
WHERE   CA1.party_id = P_party_id
And     CA1. cust_account_id = p_account_id
And     CA1.party_id = party.party_id
And     CA1.status = 'A'

UNION

SELECT  CA2.Account_number AccountNumber
      , CA2.cust_account_id AccountId
      , Party1.party_name PartyName
      , Party1.party_id PartyId
FROM    HZ_CUST_ACCOUNTS CA2
      , HZ_PARTIES party1
      , HZ_CUST_ACCT_RELATE_ALL A
      , HZ_CUST_ACCOUNTS B
WHERE   CA2.party_id = party1.party_id
And     CA2.cust_account_id = A.RELATED_CUST_ACCOUNT_ID
And     B.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
And     Ca2.cust_account_id = p_account_id
And     B.party_id = p_party_id and B.status = 'A'
And     A.status = 'A'
And     A.org_id = p_operating_unit
And     CA2.status = 'A';



 Cursor l_party_csr Is
 Select party_id
 From   HZ_CUST_ACCOUNTS CA
 Where  CA.Cust_account_id = p_new_account_Id;



Cursor Check_address_csr(l_site_use_id Number,l_party_id Number, l_account_id number, l_org_id number, l_site_use_code varchar2) Is
Select Cs.Site_Use_Id
      , Arp_Addr_Label_Pkg.Format_Address(Null,L.Address1,L.Address2,L.Address3, L.Address4, L.City, L.County, L.State, L.Province, L.Postal_Code, Null, L.Country, Null, Null, Null, Null, Null, Null, Null, 'N', 'N', 300, 1, 1) Address
From    Hz_Party_Sites Ps,Hz_Locations L
       ,Hz_Cust_Acct_Sites_All Ca,
        Hz_Cust_Site_Uses_All Cs
Where   Ps.Location_Id = L.Location_Id
And     L.Content_Source_Type = 'USER_ENTERED'
And     Ps.Party_Site_Id = Ca.Party_Site_Id
And     Ca.Cust_Acct_Site_Id = Cs.Cust_Acct_Site_Id
And     Ps.Party_Id = l_party_id
And     Ca.Cust_Account_Id = l_account_id
And     Cs.Site_Use_Code = l_site_use_code
And     Nvl (ca.Org_Id, -99) = l_org_id
And     Cs.site_use_id = l_site_use_id
And     Cs.Status = 'A'
And     Trunc(Sysdate) Between Nvl(Trunc(Ps.Start_Date_Active),
               Trunc(Sysdate)) And Nvl(Trunc(Ps.End_Date_Active), Trunc(Sysdate)) ;
--And        Ca.Cust_Acct_Site_Status = 'A';



Cursor l_contract_status_csr Is
Select code,Meaning
From   Okc_statuses_v
Where  Ste_code = 'ENTERED'
and    default_yn = 'Y';


l_bill_account_rec check_acct_csr%rowtype;
l_ship_account_rec check_acct_csr%rowtype;
l_bill_address_rec check_address_csr%rowtype;
l_ship_address_rec check_address_csr%rowtype;
l_party_id number;


Begin


      Open l_party_csr;
      Fetch l_party_csr into l_party_id;
      Close l_party_csr;
      x_credit_option := Credit_option;

      X_party_Id := l_party_id;

      Open l_contract_status_csr;
      Fetch l_contract_status_csr into X_Contract_status_code, X_contract_status;
      Close l_contract_status_csr;
      If P_Operating_unit Is not null Then
          If p_billto_Account_id is not null Then
              Open check_acct_csr(P_Billto_account_id, l_party_id);
              Fetch check_acct_csr into l_bill_account_rec;
              If check_acct_csr%found Then
                   X_BillTo_account_Number := l_bill_account_rec.AccountNumber;
                   X_BillTo_account_Id     := l_bill_account_rec.AccountId;
                   X_BillTo_Party          := l_bill_account_rec.PartyName;
                   X_BillTo_PartyId        := l_bill_account_rec.PartyId;
              End If;
              Close check_acct_csr;
              Open check_address_csr(P_BillTo_Address_Id, l_bill_account_rec.partyid,l_bill_account_rec.AccountId,p_operating_unit, 'BILL_TO');
              Fetch check_address_csr into l_bill_address_rec;
              If check_address_csr%found then

                   X_BillTo_Address_Id := l_bill_address_rec.site_use_id;
                    X_BillTo_Address    := l_bill_address_rec.Address;
              End If;
              Close check_address_csr;
       End If;

       If P_Shipto_account_id is not null Then
              Open check_acct_csr(P_Shipto_account_id, l_party_id);
              Fetch check_acct_csr into l_Ship_account_rec;
              If check_acct_csr%found Then
                   X_ShipTo_account_Number := l_Ship_account_rec.AccountNumber;
                   X_ShipTo_account_Id     := l_Ship_account_rec.AccountId;
                   X_ShipTo_Party          := l_Ship_account_rec.PartyName;
                   X_ShipTo_PartyId        := l_Ship_account_rec.PartyId;
              End If;
              Close check_acct_csr;


              Open check_address_csr(P_ShipTo_Address_Id, l_Ship_account_rec.partyid,l_Ship_account_rec.AccountId,p_operating_unit, 'SHIP_TO');
              Fetch check_address_csr into l_Ship_address_rec;
              If check_address_csr%found then

                    X_ShipTo_Address_Id := l_Ship_address_rec.site_use_id;
                    X_ShipTo_Address    := l_Ship_address_rec.Address;
              End If;
              Close check_address_csr;
        End If;
      End If;

End;

Function CheckAccount(P_batch_id Number, p_new_account_id Number) return Varchar2 Is
Cursor l_batch_csr Is
Select 'Y'
From   Oks_batch_rules
Where  new_account_id = P_new_account_id
And    batch_id = p_batch_id;

l_account_yn Varchar2(1);

Begin
        l_account_yn := 'N';
        Open l_batch_csr;
        Fetch l_batch_csr into l_account_yn;
        Close l_batch_csr;

        If l_account_yn = 'Y' Then
            return ('N');
        Else
            return ('Y');
        End If;


End;

/* ***********************************************
 *  FUnction to get the coverage terminate amount
**************************************************/
Function Coverage_terminate_amount
(P_line_id Number
,P_transfer_option Varchar2
, p_new_account_id Number
, p_transfer_date Date
, p_instance_id Number
) return number  Is

Cursor l_cust_rel_csr
(p_old_customer Number
, p_new_customer Number
, p_relation Varchar2
, p_transfer_date  Date)
Is

Select distinct relationship_type
From   Hz_relationships
Where  ((object_id = p_new_customer And subject_id = p_old_customer)
        Or     (object_id = p_old_customer And  subject_id = p_new_customer))
and    relationship_type = p_relation
And    status = 'A'
and    trunc(p_transfer_date) between trunc(start_date) and trunc(end_date)
;
Cursor l_party_csr(p_cust_id Number) Is
        Select party_id
        From   OKX_CUSTOMER_ACCOUNTS_V
        Where  id1 = p_cust_id;

Cursor l_instance_csr Is
       Select owner_party_id
       From Csi_item_instances
       Where instance_id = p_instance_id;

l_new_party_id  Number;
l_old_party_id  Number;
l_relationship  Varchar2(2000);
l_relationship_type  Varchar2(2000);

Begin


          If P_transfer_option in ('TERM_NO_REL','TRANS_NO_REL') Then

                 l_relationship_type := fnd_profile.value('OKS_TRF_PARTY_REL');

                 Open l_party_csr(p_new_account_id);
                 Fetch l_party_csr into l_new_party_id;
                 Close l_party_csr;

                 Open l_instance_csr;
                 Fetch l_instance_csr into l_old_party_id;
                 Close l_instance_csr;


                 Open l_cust_rel_csr(l_old_party_id,l_new_party_id,l_relationship_type,p_transfer_date);
                 Fetch l_cust_rel_csr into l_relationship;
                 Close l_cust_rel_csr;

                 If l_relationship Is Not Null Then
                    return (0);
                 Else
                    return(get_terminate_amount(P_line_id,p_transfer_date));
                    --return (200);

                 End If;
          Elsif P_transfer_option in ('TERM', 'TRANS') Then
                  return(get_terminate_amount(P_line_id,p_transfer_date));
                 -- return (200);

          Else

                   return (0);
          End If;

End;


Function get_full_terminate_amount
(P_line_id Number,
 P_transaction_date Date,
  P_line_End_date   Date
) return Number Is
Cursor l_line_csr Is
Select end_date
From   Okc_k_lines_b
Where id = p_line_id;

Begin


         If trunc(P_line_End_date) < trunc(P_transaction_date) Then
               return(0);
         Else

              return (get_billed_amount(p_line_id));
         End If;
End;


Function Coverage_term_full_amount
(P_line_id Number
,P_transfer_option Varchar2
, p_new_account_id Number
, p_transfer_date Date
, p_instance_id Number
,  P_line_End_date   Date

) return varchar2 Is

Cursor l_cust_rel_csr
(p_old_customer Number
, p_new_customer Number
, p_relation Varchar2
, p_transfer_date  Date)
Is

Select distinct relationship_type
From   Hz_relationships
Where  ((object_id = p_new_customer And subject_id = p_old_customer)
        Or     (object_id = p_old_customer And  subject_id = p_new_customer))
and    relationship_type = p_relation
And    status = 'A'
and    trunc(p_transfer_date) between trunc(start_date) and trunc(end_date)
;
Cursor l_party_csr(p_cust_id Number) Is
        Select party_id
        From   OKX_CUSTOMER_ACCOUNTS_V
        Where  id1 = p_cust_id;

Cursor l_instance_csr Is
       Select owner_party_id
       From Csi_item_instances
       Where instance_id = p_instance_id;

l_new_party_id  Number;
l_old_party_id  Number;
l_relationship  Varchar2(2000);
l_relationship_type  Varchar2(2000);

Begin

          If P_transfer_option in ('TERM_NO_REL','TRANS_NO_REL') Then

                 l_relationship_type := fnd_profile.value('OKS_TRF_PARTY_REL');

                 Open l_party_csr(p_new_account_id);
                 Fetch l_party_csr into l_new_party_id;
                 Close l_party_csr;

                 Open l_instance_csr;
                 Fetch l_instance_csr into l_old_party_id;
                 Close l_instance_csr;


                 Open l_cust_rel_csr(l_old_party_id,l_new_party_id,l_relationship_type,p_transfer_date);
                 Fetch l_cust_rel_csr into l_relationship;
                 Close l_cust_rel_csr;

                 If l_relationship Is Not Null Then
                    return (null);
                 Else
                    If   trunc(P_line_End_date) < trunc(P_transfer_date) Then
                          return(null);
                    Else

                        return (get_billed_amount(p_line_id));
                    End If;
                 End If;
          Elsif P_transfer_option in ('TERM','TRANS') Then
                    If  trunc(P_line_End_date) < trunc(P_transfer_date) Then
                          return(null);
                    Else

                        return (get_billed_amount(p_line_id));
                    End If;

          Else

                   return (null);
          End If;

End;
/* ***********************************************
 *  Function to get the coverage transfer amount
**************************************************/
Function Coverage_transfer_amount(P_line_id Number,P_transfer_option Varchar2, p_new_account_id Number, p_transfer_date Date, p_instance_id Number) return number  Is

Cursor l_cust_rel_csr(p_old_customer Number, p_new_customer Number, p_relation Varchar2, p_transfer_date  Date)
Is

Select distinct relationship_type
From   Hz_relationships
Where  ((object_id = p_new_customer And subject_id = p_old_customer)
        Or     (object_id = p_old_customer And  subject_id = p_new_customer))
and    relationship_type = p_relation
And    status = 'A'
and    trunc(p_transfer_date) between trunc(start_date) and trunc(end_date)
;
Cursor l_party_csr(p_cust_id Number) Is
        Select party_id
        From   OKX_CUSTOMER_ACCOUNTS_V
        Where  id1 = p_cust_id;

Cursor l_instance_csr Is
       Select owner_party_id
       From Csi_item_instances
       Where instance_id = p_instance_id;

l_new_party_id  Number;
l_old_party_id  Number;
l_relationship  Varchar2(2000);
l_relationship_type  Varchar2(2000);
trf_amount  Number;

Begin

          If P_transfer_option in ('TRANS_NO_REL') Then

                 l_relationship_type := fnd_profile.value('OKS_TRF_PARTY_REL');

                 Open l_party_csr(p_new_account_id);
                 Fetch l_party_csr into l_new_party_id;
                 Close l_party_csr;

                 Open l_instance_csr;
                 Fetch l_instance_csr into l_old_party_id;
                 Close l_instance_csr;


                 Open l_cust_rel_csr(l_old_party_id,l_new_party_id,l_relationship_type,p_transfer_date);
                 Fetch l_cust_rel_csr into l_relationship;
                 Close l_cust_rel_csr;

                 If l_relationship Is Not Null Then
                    return (0);
                 Else
                    trf_amount := get_transferred_amount(p_line_id,p_transfer_date);
                    return (trf_amount);
                 End If;
          Elsif P_transfer_option in ('TRANS') Then
                 --errorout_n('in  cov trf');
                  trf_amount := get_transferred_amount(p_line_id,p_transfer_date);
                  return (trf_amount);

          Else
                   return (0);
          End If;

End;


Function Get_date_terminated
        ( P_sts_code  varchar2,
          P_Transaction_date  Date,
          P_Start_date  Date,
          P_end_date  Date)
Return Date Is

begin

If P_sts_code = 'ENTERED' Then
     return(Null);
Else
     If trunc(p_transaction_date) < trunc(p_start_date) Then
         return(P_start_date);
     Elsif trunc(p_transaction_date) between trunc(p_start_date) And trunc(p_end_date) Then
         return(p_transaction_date);
     Elsif trunc(p_transaction_date) > trunc(p_end_date) Then
         return(p_end_date+1);
     End If;

End If;

End;



/* ***********************************************
 *  Procedure to populate the Global temporary table
 * with the impacted COntracts
**************************************************/
Procedure Populate_GlobalTemp(P_Batch_Id Number, P_Batch_type Varchar2, p_transaction_date Date default sysdate, P_new_account_id Number default null)  Is

Cursor Contracts_for_transfer_csr Is
      Select            Tmp.Instance_Id
                      , KI.CLE_ID SubLine_id
                      , KI.Dnz_Chr_Id
                      , KL.Cle_Id
                      , nvl(KL.price_negotiated,0)
                      , get_transferred_amount(KI.CLE_ID,p_transaction_date) Transfer_amount
                      , get_terminate_amount(KI.CLE_ID, p_transaction_date) Credit_Amount
                      , get_full_terminate_amount(KI.CLE_ID, p_transaction_date,Kl.end_date) Full_terminate_amount
                      , get_billed_amount(Ki.cle_id) Billed_Amount
                      , Coverage_transfer_amount(KI.CLE_ID,Ks1.transfer_option, p_new_account_id,p_transaction_date,tmp.instance_id)    --coverage transfer amount
                      , Coverage_terminate_amount(KI.CLE_ID,Ks1.transfer_option,p_new_account_id,p_transaction_date,tmp.instance_id) Coverage_terminate_amount        --coverage terminate amount
                      , Coverage_term_full_amount(KI.Cle_id,Ks1.transfer_option,p_new_account_id,p_transaction_date,tmp.instance_id,kl.end_date) Coverage_full_amount
                      , Get_date_terminated(St.ste_code,p_transaction_date,kl.start_date, kl.end_date)

           From         OKC_K_ITEMS KI
                      , OKC_K_HEADERS_all_B KH
                      , OKC_K_LINES_B   KL
	                  , OKC_STATUSES_B ST
                      , Oks_Instance_k_dtls_temp tmp
                      , OKS_K_LINES_B KS
                      , OKS_K_LINES_B KS1
                      ,OKC_STATUSES_B HST

           Where   tmp.parent_id = p_batch_id
           And     KI.Object1_id1 = to_char(tmp.instance_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
           And     KI.Cle_id = KL.id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED','HOLD')
	   And     KH.sts_code = HST.code
           And     HST.ste_code <> 'HOLD'
           And     KL.date_terminated Is Null
           And     KH.template_yn = 'N'
           And     KS.cle_id = KL.cle_Id
           And     KS1.cle_id = KS.Coverage_id
           And   ( (trunc(p_transaction_date) <= trunc(KL.end_date)And trunc(p_transaction_date) >= trunc(KL.start_date))
                   OR (trunc(p_transaction_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(p_transaction_date) and Kl.lse_id <> 18
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id)
                      )
                   );


Cursor Contracts_for_terminate_csr Is
 Select                 Tmp.Instance_Id
                      , KI.CLE_ID SubLine_id
                      , KI.Dnz_Chr_Id
                      , KL.Cle_Id
                      , KL.price_negotiated
                      , 0 Transfer_amount
                      , get_terminate_amount(KI.CLE_ID, p_transaction_date) Credit_Amount
                      , get_full_terminate_amount(KI.CLE_ID, p_transaction_date,Kl.end_date) Full_terminate_amount
                      , get_billed_amount(KI.CLE_ID)   Billed_Amount
                      , 0
                      , 0
                      , 0
                      , Get_date_terminated(St.ste_code,p_transaction_date,kl.start_date, Kl.end_date)
           From         OKC_K_ITEMS KI
                      , OKC_K_HEADERS_ALL_B KH
                      , OKC_K_LINES_B   KL
	                  , OKC_STATUSES_B ST
                      ,  Oks_Instance_k_dtls_temp tmp
		      , OKC_STATUSES_B HST
           Where    tmp.parent_id = p_batch_id
           And     KI.Object1_id1 = to_char(tmp.instance_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
           And     KI.Cle_id = KL.id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED','HOLD')
	   And     KH.sts_code = HST.code
           And     HST.ste_code <> 'HOLD'
           And     KL.date_terminated Is Null
           And     KH.template_yn = 'N'
           And   ( (trunc(p_transaction_date) <= trunc(KL.end_date)And trunc(p_transaction_date) >= trunc(KL.start_date))
                   OR (trunc(p_transaction_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(p_transaction_date) and Kl.lse_id <> 18
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id
                                         )
                   )
                )


	Union

          Select        Tmp.Instance_Id
                      , KI.CLE_ID SubLine_id
                      , KI.Dnz_Chr_Id
                      , KL.Cle_Id
                      , nvl(KL.price_negotiated,0)
                      , 0 Transfer_amount
                      , get_terminate_amount(KI.CLE_ID, p_transaction_date) Credit_Amount
                      , get_full_terminate_amount(KI.CLE_ID, p_transaction_date,Kl.end_date) Full_terminate_amount
                      , get_billed_amount(KI.CLE_ID)   Billed_Amount
                      , 0
                      , 0
                      , 0
                      , Get_date_terminated(St.ste_code,p_transaction_date,kl.start_date, Kl.end_date)
	           From    OKC_K_ITEMS   KI
	                  ,OKC_K_HEADERS_ALL_B KH
	                  ,OKC_K_LINES_B   KL
	                  ,OKC_STATUSES_B  ST
	                  ,csi_counter_associations ctrAsc
                      ,  Oks_Instance_k_dtls_temp tmp
		      ,  OKC_STATUSES_B HST

	           Where    tmp.parent_id = p_batch_id
               And      KI.object1_id1 = to_char(ctrAsc.Counter_id)
               And      ctrAsc.source_object_id =    tmp.instance_id
	           And     jtot_object1_code = 'OKX_COUNTER'
	           And     KI.dnz_chr_id = KH.ID
	           And     KH.scs_code in ('SERVICE','SUBSCRIPTION')
	           And     KI.Cle_id = KL.id
	           And     KL.sts_code = ST.code
	           And     ST.ste_code not in ('TERMINATED','CANCELLED','HOLD')
		   And     KH.sts_code = HST.code
                   And     HST.ste_code <> 'HOLD'
	           And     KL.date_terminated Is Null
	           And     KH.template_yn = 'N'

           And   ( (trunc(p_transaction_date) <= trunc(KL.end_date)And trunc(p_transaction_date) >= trunc(KL.start_date))
                   OR (trunc(p_transaction_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(p_transaction_date)
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id)
                      )
                   )
	          ;

	Cursor Contracts_for_idc_Csr Is
           Select       Tmp.Instance_Id
                      , KI.CLE_ID SubLine_id
                      , KI.Dnz_Chr_Id
                      , KL.Cle_Id
                      , nvl(KL.price_negotiated,0)
                      , 0 Transfer_amount
                      , 0 Credit_Amount
                      , 0 Full_terminate_amount
	                , 0 Billed_Amount
                      , 0
                      , 0
                      , 0
                      , null
	           From    OKC_K_ITEMS_V   KI
	                  , OKC_K_HEADERS_ALL_B KH
		              , OKC_K_LINES_B   KL
	                  , OKC_STATUSES_B  ST
	                  , OKS_K_LINES_B KS
                          , Oks_k_lines_b KS1
                      ,  Oks_Instance_k_dtls_temp tmp
               Where    tmp.parent_id = p_batch_id
               And     KI.Object1_id1 = to_char(tmp.instance_id)
	           And    KI.Jtot_Object1_code = 'OKX_CUSTPROD'
	           And     KI.dnz_chr_id = KH.ID
	           And     KH.scs_code ='WARRANTY'
	           And     KI.Cle_id = KL.id
	           And     KL.sts_code = ST.code
	           AND     KL.CLE_ID = KS.CLE_ID
                   AND     KS.Coverage_ID = KS1.Cle_id
	           And     ST.ste_code not in ('TERMINATED','CANCELLED')
	           And     KL.date_terminated Is Null
	            And     KH.template_yn = 'N'
	           AND     KL.lse_id = 18
	           AND     nvl(ks1.sync_date_install,'N') = 'Y';
               --And     (check_sr_exists_yn(tmp.instance_id,Kl.cle_id) = 'N') ;


              Type instance_rec is record
              (
                instance_id number
              );
              Type item_inst_tbl is table of number index  by BINARY_INTEGER ;
              l_item_inst_tbl            item_inst_tbl;
              Type l_num_tbl is table of NUMBER index  by BINARY_INTEGER ;
              Type l_Date_tbl is table of Date index  by BINARY_INTEGER ;

              Subline_tbl         l_num_tbl ;
              Instance_tbl        l_num_tbl ;

              COntract_tbl        l_num_tbl ;
              Line_tbl            l_num_tbl ;
              Amount_tbl          l_num_tbl ;
              Transfer_amount_tbl l_num_tbl ;
              Credit_amount_tbl   l_num_tbl ;
              full_credit_amt_tbl  l_num_tbl;
              Date_Terminated_tbl l_Date_tbl ;
	          billed_amount_tbl   l_num_tbl ;
	          Coverage_trf_amount_tbl    l_num_tbl ;
              Coverage_credit_amount_tbl l_num_tbl ;
              Coverage_credit_fullamt_tbl l_num_tbl ;


             -- l_item_inst_tbl     item_inst_tbl;
              l_instance_id       number;
              l_batch_id          number;

              l_txn_rec           CSI_UTILITY_GRP.txn_oks_rec;
              l_item_instance_tbl     CSI_UTILITY_GRP.txn_inst_tbl;
              l_return_status     Varchar2(1);
              l_msg_count         Number;
              l_msg_data          Varchar2(2000);
              l_count number;
Begin
          --call IB api to return instances

            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.POPULATE_GLOBAL_TEMP',
                                    'batch_id= ' ||p_batch_id );
            End If;
            l_txn_rec.batch_id := p_batch_id;
            If p_batch_type = 'XFER' then
                l_txn_rec.transaction_type(1) := 'TRF';
            Elsif p_batch_type = 'TRM' Then
                l_txn_rec.transaction_type(1) := 'TRM';
            Else
                l_txn_rec.transaction_type(1) := 'IDC';
            End If;
            CSI_UTILITY_GRP.Get_impacted_item_instances
           (
             p_api_version           => 1.0
            ,p_commit                => 'F'
            ,p_init_msg_list         => okc_api.g_false
            ,p_validation_level      => fnd_api.g_valid_level_full
            ,x_txn_inst_tbl          => l_item_instance_tbl
            ,p_txn_oks_rec           => l_txn_rec
            ,x_return_status         => l_return_status
            ,x_msg_count             => l_msg_count
            ,x_msg_data              => l_msg_data
           );
/*

l_item_instance_tbl(1).transaction_type := 'TRF';
--l_item_instance_tbl(1).instance_tbl(1) := 148664;
--l_item_instance_tbl(1).instance_tbl(2) := 152662;
l_item_instance_tbl(1).instance_tbl(1) := 236663;

*/
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.POPULATE_GLOBAL_TEMP',
                                    'l_item_instance_tbl.count = ' ||l_item_instance_tbl.count );

            End If;
If l_item_instance_tbl.count > 0 Then
          If p_batch_type = 'XFER' Then

              For i in l_item_instance_tbl.first ..l_item_instance_tbl.last
              Loop
                  If l_item_instance_tbl(i).transaction_type = 'TRF' Then

                       Delete  Oks_Instance_k_dtls_temp ;
                       IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                             fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.POPULATE_GLOBAL_TEMP',
                                    'Insert inot temp ');

                       End If;
                       FORALL j in l_item_instance_tbl(i).instance_tbl.first..l_item_instance_tbl(i).instance_tbl.last
                       INSERT INTO  Oks_Instance_k_dtls_temp
                       (
                         parent_id ,
                         subline_id,
                         topline_id ,
                         contract_id,
                         billed_amount                  ,
                         transfer_amount                ,
                         credit_amount                  ,
                         amount                         ,
                         new_subline_id                 ,
                         new_serviceline_id             ,
                         new_contract_id                ,
                         instance_id                    ,
                         cov_trf_amt                    ,
                         cov_trm_amount                 ,
                         cov_billed_amount              ,
                         new_start_date                 ,
                         new_end_date                   ,
                         date_terminated               ,
                         full_term_amount


                       )
                       Values (
                       p_batch_id,null,null,null,null,null,null,null,null,null,null,l_item_instance_tbl(i).instance_tbl(j) ,NULL,NULL,NULL,NULL,NULL,NULL ,Null);

                      Open Contracts_for_transfer_csr;
                       Fetch Contracts_for_transfer_csr bulk collect into
                        Instance_tbl
                      ,  SubLine_tbl
                      , COntract_tbl
                      , Line_tbl
                      , Amount_tbl
                      , Transfer_amount_tbl
                      , Credit_amount_tbl
                      , full_credit_amt_tbl
	               , billed_amount_tbl
                      , Coverage_trf_amount_tbl
                      , Coverage_credit_amount_tbl
                      , Coverage_credit_fullamt_tbl
                      , Date_terminated_tbl;
                      Close Contracts_for_transfer_csr;
                  End If;
              End Loop;

          Elsif p_batch_type = 'TRM' Then
              For i in l_item_instance_tbl.first ..l_item_instance_tbl.last
              Loop
                If l_item_instance_tbl(i).transaction_type = 'TRM' Then

                        Delete  Oks_Instance_k_dtls_temp ;

                       FORALL j in l_item_instance_tbl(i).instance_tbl.first..l_item_instance_tbl(i).instance_tbl.last
                       INSERT INTO  Oks_Instance_k_dtls_temp
                       (
                         parent_id ,
                         subline_id,
                         topline_id ,
                         contract_id,
                         billed_amount                  ,
                         transfer_amount                ,
                         credit_amount                  ,
                         amount                         ,
                         new_subline_id                 ,
                         new_serviceline_id             ,
                         new_contract_id                ,
                         instance_id                    ,
                         cov_trf_amt                    ,
                         cov_trm_amount                 ,
                         cov_billed_amount              ,
                         new_start_date                 ,
                         new_end_date                   ,
                         date_terminated               ,
                         full_term_amount


                       )
                      Values (
                       p_batch_id,null,null,null,null,null,null,null,null,null,null,l_item_instance_tbl(i).instance_tbl(j) ,NULL,NULL,NULL,NULL,NULL,NULL,null );

                       Open Contracts_for_terminate_csr;
                       Fetch Contracts_for_terminate_csr bulk collect into
                        Instance_tbl
                      ,  SubLine_tbl
                      , COntract_tbl
                      , Line_tbl
                      , Amount_tbl
                      , Transfer_amount_tbl
                      , Credit_amount_tbl
                      , full_credit_amt_tbl
	              , billed_amount_tbl
                      , Coverage_trf_amount_tbl
                      , Coverage_credit_amount_tbl
                      , Coverage_credit_fullamt_tbl
                      , Date_terminated_tbl;
                       Close Contracts_for_terminate_csr;
                 End If;
              End Loop;
            Else
              For i in l_item_instance_tbl.first ..l_item_instance_tbl.last
              Loop
                 If l_item_instance_tbl(i).transaction_type = 'IDC' Then
                    Delete  Oks_Instance_k_dtls_temp ;

                    FORALL j in l_item_instance_tbl(i).instance_tbl.first..l_item_instance_tbl(i).instance_tbl.last
                       INSERT INTO  Oks_Instance_k_dtls_temp
                       (
                         parent_id ,
                         subline_id,
                         topline_id ,
                         contract_id,
                         billed_amount                  ,
                         transfer_amount                ,
                         credit_amount                  ,
                         amount                         ,
                         new_subline_id                 ,
                         new_serviceline_id             ,
                         new_contract_id                ,
                         instance_id                    ,
                         cov_trf_amt                    ,
                         cov_trm_amount                 ,
                         cov_billed_amount              ,
                         new_start_date                 ,
                         new_end_date                   ,
                         date_terminated               ,
                         full_term_amount


                       )
                       Values (
                       p_batch_id,null,null,null,null,null,null,null,null,null,null,l_item_instance_tbl(i).instance_tbl(j) ,NULL,NULL,NULL,NULL,NULL,NULL,null );

                     Open Contracts_for_idc_csr;
                     Fetch Contracts_for_idc_csr bulk collect into
                        Instance_tbl
                      , SubLine_tbl
                      , COntract_tbl
                      , Line_tbl
                      , Amount_tbl
                      , Transfer_amount_tbl
                      , Credit_amount_tbl
                      ,full_credit_amt_tbl
	              , billed_amount_tbl
                      , Coverage_trf_amount_tbl
                      , Coverage_credit_amount_tbl
                      , Coverage_credit_fullamt_tbl
                      , Date_terminated_tbl;
                     Close Contracts_for_idc_csr;
                 End If;
               End Loop;

             End If;

End If;

      Delete  Oks_Instance_k_dtls_temp;-- where parent_id = p_batch_id;
            If Subline_tbl.count > 0 Then
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.POPULATE_GLOBAL_TEMP',
                                    'Subline_tbl.count = ' ||Subline_tbl.count );

            End If;

            FORALL i in Subline_tbl.FIRST..Subline_tbl.LAST
               INSERT INTO  Oks_Instance_k_dtls_temp
               (
                         parent_id ,
                         subline_id,
                         topline_id ,
                         contract_id,
                         billed_amount                  ,
                         transfer_amount                ,
                         credit_amount                  ,
                         amount                         ,
                         new_subline_id                 ,
                         new_serviceline_id             ,
                         new_contract_id                ,
                         instance_id                    ,
                         cov_trf_amt                    ,
                         cov_trm_amount                 ,
                         cov_billed_amount              ,
                         new_start_date                 ,
                         new_end_date                   ,
                         date_terminated               ,
                         full_term_amount


                )
               Values
               ( p_Batch_id
               , SubLine_tbl(i)
               , Line_tbl(i)
               , COntract_tbl(i)
               , billed_amount_tbl(i)
               , Transfer_amount_tbl(i)
               , Credit_amount_tbl(i)
               , Amount_tbl(i)
               , Null
               , Null
               , Null
               , Instance_tbl(i)
	           , Coverage_trf_amount_tbl(i)
	           , Coverage_credit_amount_tbl(i)
               , Coverage_credit_fullamt_tbl(i)
	           , NULL
	           , Null
                ,Date_terminated_tbl(i)
               , full_credit_amt_tbl(i)

               );


               End If;


End;

   FUNCTION get_invoice_text (
      p_product_item   IN   NUMBER,
      p_start_date     IN   DATE,
      p_end_date       IN   DATE
   )
      RETURN VARCHAR2
   IS
      CURSOR l_inv_csr (p_product_item NUMBER)
      IS
         SELECT t.description NAME,
                b.concatenated_segments description
           FROM mtl_system_items_b_kfv b, mtl_system_items_tl t
          WHERE b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.inventory_item_id = p_product_item
            AND ROWNUM < 2;

      l_object_code                 okc_k_items.jtot_object1_code%TYPE;
      l_object1_id1                 okc_k_items.object1_id1%TYPE;
      l_object1_id2                 okc_k_items.object1_id2%TYPE;
      l_no_of_items                 okc_k_items.number_of_items%TYPE;
      l_name                        VARCHAR2 (2000);
      l_desc                        VARCHAR2 (2000);
      l_formatted_invoice_text      VARCHAR2 (2000);
   BEGIN
      OPEN l_inv_csr (p_product_item);

      FETCH l_inv_csr
       INTO l_name,
            l_desc;

      CLOSE l_inv_csr;

      IF fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE') = 'DISPLAY_DESC'
      THEN
         l_desc                                    := l_name;
      ELSE
         l_desc                                    := l_desc;
      END IF;

      l_formatted_invoice_text                  :=
         SUBSTR (l_desc || ':' || p_start_date || ':' || p_end_date,
                 1,
                 450
                );
      RETURN (l_formatted_invoice_text);
   END get_invoice_text;



/* ***********************************************
 *  Procedure to check if all the sublines and top lines
 * in a contract are terminated or cancelled.
**************************************************/
     Procedure Check_termcancel_lines
     (
        p_line_id Number      -- TOp line id or Header Id
      , p_line_type Varchar2  -- 'TL' or 'SL'
      , P_txn_type Varchar2   --'T' for termination, 'C' for cancel
      , X_date     OUT NOCOPY Date
      )  Is
     Cursor l_Term_subline_csr Is
     Select max(date_terminated)
     From   OKC_K_LINES_B
     Where  cle_id = p_line_id
     and lse_id in (8,7,9,10,11,18,13,25,35)
     having Count(*) = count(decode(date_terminated, null, null, 'x')) ;

     Cursor l_term_topline_csr Is
     Select max(date_terminated)
     From   OKC_K_LINES_B
     Where  dnz_chr_id = p_line_id
     and lse_id in (1,12,14,19)
     having Count(*) = count(decode(date_terminated, null, null, 'x'));

     Cursor l_Cancel_subline_csr Is
     Select max(date_cancelled)
     From   OKC_K_LINES_B
     Where  cle_id = p_line_id
     and lse_id in (8,7,9,10,11,18,13,25,35)
     having count(*) = Count(decode(term_cancel_source,'IBTRANSFER','x','IBTERMINATE','x','IBRETURN','x',null))
     and  Count(*) = count(decode(date_cancelled, null, null, 'x')) ;

     Cursor l_Cancel_topline_csr Is
     Select max(date_cancelled)
     From   OKC_K_LINES_B
     Where  dnz_chr_id = p_line_id
     and lse_id in (1,12,14,19)
     having count(*) = Count(decode(term_cancel_source,'IBTRANSFER','x','IBTERMINATE','x','IBRETURN','x',null))
     and  Count(*) = count(decode(date_cancelled, null, null, 'x'));

     l_date date;
     Begin

     l_date := null;
     If P_txn_type = 'T' Then
       If P_line_type = 'SL' Then
          Open l_Term_subline_csr;
          Fetch l_Term_subline_csr into l_date;
          Close l_Term_subline_csr;

        Else
          Open l_Term_topline_csr;
          Fetch l_Term_topline_csr into l_date;
          Close l_Term_topline_csr;


        End If;

     Else
        If P_line_type = 'SL' Then
          Open l_Cancel_subline_csr;
          Fetch l_Cancel_subline_csr into l_date;
          Close l_Cancel_subline_csr;

        Else

          Open l_Cancel_Topline_csr;
          Fetch l_Cancel_Topline_csr into l_date;
          Close l_Cancel_Topline_csr;

        End If;
     End If;

     X_date := l_date;

End;

FUNCTION get_credit_option (
   p_party_id                          NUMBER,
   p_org_id                            NUMBER,
   p_transaction_date                  DATE
)
   RETURN VARCHAR2
IS
   CURSOR credit_option_csr
   IS
      SELECT credit_amount
        FROM oks_k_defaults
       WHERE (    segment_id1 = p_party_id
              AND segment_id2 = '#'
              AND jtot_object_code = 'OKX_PARTY'
              AND cdt_type = 'SDT'
              AND p_transaction_date BETWEEN start_date
                                         AND NVL (end_date,
                                                  p_transaction_date)
             )
          OR (    segment_id1 = p_org_id
              AND segment_id2 = '#'
              AND jtot_object_code = 'OKX_OPERUNIT'
              AND cdt_type = 'SDT'
              AND p_transaction_date BETWEEN start_date
                                         AND NVL (end_date,
                                                  p_transaction_date)
             )
order by jtot_object_code desc;
Cursor l_global_csr Is
Select credit_option
From oks_k_defaults
Where cdt_type = 'MDT'
AND segment_id1 IS NULL
AND segment_id2 IS NULL
AND jtot_object_code IS NULL
             ;

   l_credit_option   VARCHAR2 (30);
BEGIN
   FOR credit_option_rec IN credit_option_csr
   LOOP
      l_credit_option := credit_option_rec.credit_amount;

      IF l_credit_option IS NOT NULL
      THEN
         EXIT;
      END IF;
   END LOOP;

   IF l_credit_option IS NULL
   THEN
        Open l_global_csr;
        Fetch l_global_csr into l_credit_option;
        Close l_global_csr;
        If l_credit_option Is Null Then


            IF NVL (fnd_profile.VALUE ('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT'), 'YES') =
                                                                          'YES'
            THEN
                l_credit_option := 'CALCULATED';
            ELSE
                l_credit_option := 'NONE';
            END IF;
        End If;
   END IF;

   RETURN (l_credit_option);
END;


-- Function to get the credit amount based on GCD and pofile.

FUNCTION get_credit_amount_trm (
   p_line_id                  IN       NUMBER,
   p_termination_date         IN       DATE DEFAULT NULL
)
   RETURN NUMBER
IS
   l_amount              NUMBER;
   l_return_status       VARCHAR2 (1);
   x_msg_data            VARCHAR2 (2000);
   x_msg_count           NUMBER;
   l_rnrl_rec_out        oks_renew_util_pvt.rnrl_rec_type;
   l_calculated_credit   VARCHAR2 (1)                     := 'N';
   l_party_id            NUMBER;
   l_org_id              NUMBER;
   l_inv_org_id              NUMBER;
   CURSOR get_party_csr
   IS
      SELECT prl.object1_id1 party_id,
             kh.authoring_org_id org_id,
             kh.inv_organization_id
        FROM okc_k_party_roles_b prl,
             okc_k_headers_all_b kh,
             okc_k_lines_b ksl
       WHERE ksl.ID = p_line_id
         AND ksl.dnz_chr_id = kh.ID
         AND prl.dnz_chr_id = kh.ID
         AND prl.chr_id IS NOT NULL
         AND prl.cle_id IS NULL
         AND prl.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
         AND prl.jtot_object1_code = 'OKX_PARTY';


BEGIN
   OPEN get_party_csr;

   FETCH get_party_csr
    INTO l_party_id,
         l_org_id,
         l_inv_org_id;

   CLOSE get_party_csr;

   oks_renew_util_pub.get_renew_rules (p_api_version        => 1.0,
                                       p_init_msg_list      => 'T',
                                       x_return_status      => l_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data,
                                       p_chr_id             => NULL,
                                       p_party_id           => l_party_id,
                                       p_org_id             => l_org_id,
                                       p_date               => SYSDATE,
                                       p_rnrl_rec           => NULL,
                                       x_rnrl_rec           => l_rnrl_rec_out
                                      );

   IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
   THEN
      fnd_log.STRING
                    (fnd_log.level_event,
                     g_module_current || '.get_credit_amount',
                        'oks_renew_util_pub.get_renew_rules(Return status = '
                     || l_return_status
                     || ') Credit amount = ('
                     || l_rnrl_rec_out.credit_amount
                     || ')'
                    );
   END IF;

   IF NOT l_return_status = okc_api.g_ret_sts_success
   THEN
      RAISE g_exception_halt_validation;
   END IF;

   IF UPPER (l_rnrl_rec_out.credit_amount) = 'FULL'
   THEN
      RETURN (get_billed_amount (p_line_id));
   ELSIF UPPER (l_rnrl_rec_out.credit_amount) = 'NONE'
   THEN
      RETURN (0);
   ELSIF l_rnrl_rec_out.credit_amount IS NULL
   THEN
      -- get the profile value of oks_raise_credit.....
      IF NVL (fnd_profile.VALUE ('OKS_RAISE_CREDIT_MEMO_FOR_IB_INT'), 'YES') = 'YES'
      THEN
         l_calculated_credit := 'Y';
      END IF;
   ELSIF UPPER (l_rnrl_rec_out.credit_amount) = 'CALCULATED'
   THEN
      l_calculated_credit := 'Y';
   END IF;

   IF l_calculated_credit = 'Y'
   THEN


      okc_context.set_okc_org_context (l_org_id, l_inv_org_id);
      oks_bill_rec_pub.pre_terminate_amount
                               (p_id                  => p_line_id,
                                p_terminate_date      => trunc(NVL(p_termination_date,SYSDATE)),
                                p_flag                => 3,
                                x_amount              => l_amount,
                                x_return_status       => l_return_status
                               );
      RETURN (l_amount);
   ELSE
      RETURN (0);
   END IF;
END;

FUNCTION get_credit_amount_trf (
   p_line_id                           NUMBER,
   p_new_account_id                    NUMBER,
   p_transfer_date                     DATE
)
   RETURN NUMBER
IS

CURSOR l_get_attr_csr IS
SELECT csi.OWNER_PARTY_ID old_party_id,
       tls1.TRANSFER_OPTION transfer_option

FROM okc_k_lines_b sl,
oks_k_lines_b tls,
oks_k_lines_b tls1,
okc_k_items im,
csi_item_instances csi

WHERE sl.id = p_line_id
AND  sl.id = im.cle_id
AND  im.jtot_object1_code = 'OKX_CUSTPROD'
AND  im.object1_id1 = csi.instance_id
AND  sl.cle_id = tls.cle_id
AND  tls.coverage_id = tls1.CLE_ID;

   CURSOR l_cust_rel_csr (
      p_old_customer                      NUMBER,
      p_new_customer                      NUMBER,
      p_relation                          VARCHAR2,
      p_transfer_date                     DATE
   )
   IS
      SELECT DISTINCT relationship_type
                 FROM hz_relationships
                WHERE (   (    object_id = p_new_customer
                           AND subject_id = p_old_customer
                          )
                       OR (    object_id = p_old_customer
                           AND subject_id = p_new_customer
                          )
                      )
                  AND relationship_type = p_relation
                  AND status = 'A'
                  AND TRUNC (p_transfer_date) BETWEEN TRUNC (start_date)
                                                  AND TRUNC (end_date);

   CURSOR l_party_csr (
      p_cust_id                           NUMBER
   )
   IS
      SELECT party_id
        FROM okx_customer_accounts_v
       WHERE id1 = p_cust_id;

   l_new_party_id        NUMBER;
   l_old_party_id        NUMBER;
   l_relationship        VARCHAR2 (2000);
   l_relationship_type   VARCHAR2 (2000);
   l_get_attr_rec        l_get_attr_csr%ROWTYPE;
BEGIN
      OPEN l_get_attr_csr;
      FETCH l_get_attr_csr INTO l_get_attr_rec;
      CLOSE l_get_attr_csr;

   IF l_get_attr_rec.transfer_option IN ('TERM_NO_REL', 'TRANS_NO_REL')
   THEN
      l_relationship_type := fnd_profile.VALUE ('OKS_TRF_PARTY_REL');

      OPEN l_party_csr (p_new_account_id);
      FETCH l_party_csr INTO l_new_party_id;
      CLOSE l_party_csr;

      OPEN l_cust_rel_csr (l_get_attr_rec.old_party_id,
                           l_new_party_id,
                           l_relationship_type,
                           p_transfer_date
                          );

      FETCH l_cust_rel_csr
       INTO l_relationship;

      CLOSE l_cust_rel_csr;

      IF l_relationship IS NULL
      THEN
         RETURN (0);
      ELSE
        RETURN (get_credit_amount_trm (p_line_id,
                                        p_transfer_date ));

      END IF;
   ELSIF l_get_attr_rec.transfer_option IN ('TERM', 'TRANS')
   THEN
      RETURN (get_credit_amount_trm (p_line_id,
                                     p_transfer_date));
   ELSE
      RETURN (0);
   END IF;

END;



   Function  Check_renewed_Sublines
     (
        p_line_id Number

      ) return Date  Is
     Cursor l_line_csr Is
     Select max(Kl.date_renewed)
     From   OKC_K_LINES_B Kl, OKc_k_lines_b Kl1
     Where  Kl1.id = p_line_id
     and    Kl.cle_id = Kl1.cle_id
     And    Kl.lse_id in (8,7,9,10,11,13,35, 18, 25)
     having Count(*) = count(decode(kl.date_renewed, null, null, 'x')) ;


     l_date  Date;



   Begin

          Open l_line_csr;
          Fetch l_line_csr into l_date;
          Close l_line_csr;

          return(l_date);
   End ;


   Function Check_renewed_lines
     (
        p_line_id Number

      ) return Date  Is
     Cursor l_line_csr Is
     Select max(Kl.date_renewed)
     From   OKC_K_LINES_B Kl, Okc_k_lines_b Kl1
     Where  Kl1.Id = p_line_id
     And    Kl.dnz_chr_id = Kl1.dnz_chr_id
     and    Kl.lse_id in (1,12,19)
     having Count(*) = count(decode(Kl.date_renewed, null, null, 'x')) ;

     l_date  Date;

   Begin

          Open l_line_csr;
          Fetch l_line_csr into l_date;
          Close l_line_csr;

          return(l_date);





End;

     Function Check_Termination_date
     (
        p_line_id Number      -- TOp line id or Header Id
      , P_Line_type Varchar2   --'T' for TopLine, 'H' for Header
     )  Return Date Is


   CURSOR get_line_term
   IS
      SELECT max(date_terminated)
        FROM oks_Instance_k_dtls_temp temp
       where topline_id = p_Line_id
       having count(*) = (select count(*) from Okc_k_lines_b
                           WHERE cle_id = p_line_id AND lse_id IN (8,7,9,10,11,13,35, 18, 25)
                          );


   CURSOR get_max_line_term
   IS
      SELECT max(date_terminated)
        FROM oks_Instance_k_dtls_temp temp
       where topline_id = p_Line_id;



     Cursor l_term_topline_csr Is
     Select max(line.date_terminated)
     From   OKC_K_LINES_B line
     Where  line.cle_id= p_line_id
     and    line.lse_id in (8,7,9,10,11,13,18,25,35)
     And    line.id not in (select subline_id from oks_instance_k_dtls_temp where topline_id = p_line_id)
     having Count(line.id) = count(decode(line.date_terminated, null, null, 'x'));



   CURSOR get_Hdr_term
   IS
      SELECT max(date_terminated)
        FROM oks_Instance_k_dtls_temp
       where contract_id = p_Line_id
       having count(*) = (select count(*) from Okc_k_lines_b
                           WHERE dnz_chr_id= p_line_id AND lse_id IN (8,7,9,10,11,13,35, 18, 25)
                          );



   CURSOR get_max_Hdr_term
   IS
      SELECT max(date_terminated)
        FROM oks_Instance_k_dtls_temp temp
       where Contract_id = p_Line_id;




     Cursor l_term_Hdr_csr Is
     Select max(line.date_terminated)
     From   OKC_K_LINES_B line
     Where  line.dnz_chr_id= p_line_id
     and    line.lse_id in (8,7,9,10,11,13,18,25,35)
     And    line.id not in (select subline_id from oks_instance_k_dtls_temp where Contract_id = p_line_id)
     having Count(*) = count(decode(line.date_terminated, null, null, 'x'));

     l_line_date   Date;
     l_Hdr_date   Date;
     l_line_term_dt   Date;
     l_HDr_term_dt    Date;



     Begin


    If P_line_type = 'T' Then

          l_line_term_dt := Null;
          Open get_line_term;
          Fetch get_line_term into l_line_term_dt;
          Close get_line_term;

          If l_line_term_dt Is Null Then
             Open l_term_topline_csr ;
             Fetch l_term_topline_csr into l_line_Date;
             Close l_term_topline_csr ;




             If l_line_date Is Not Null Then
                 Open get_max_line_term ;
                 Fetch get_max_line_term into l_line_term_dt;
                 Close get_max_line_term ;
                 l_line_term_dt := greatest(l_line_date,l_line_term_dt);
             Else
                 l_line_term_dt := Null;
             End if;
           End If;

           return(l_line_term_dt);



      End If;

      If P_line_type = 'H' Then

           l_Hdr_term_dt := Null;
          Open get_Hdr_term;
          Fetch get_Hdr_term into l_Hdr_term_dt;
          Close get_Hdr_term;

          If l_Hdr_term_dt Is Null Then
             Open l_term_Hdr_csr ;
             Fetch l_term_Hdr_csr into l_Hdr_Date;
             Close l_term_Hdr_csr ;




             If l_Hdr_date Is Not Null Then
                 Open get_max_Hdr_term ;
                 Fetch get_max_Hdr_term into l_Hdr_term_dt;
                 Close get_max_Hdr_term ;
                 l_Hdr_term_dt := greatest(l_Hdr_date,l_Hdr_term_dt);
             Else
                 l_Hdr_term_dt := Null;
             End if;
           End If;

          Return(l_Hdr_term_dt);
      End If;




End;

Function Get_address(P_site_use_id Number) return varchar2 Is

Cursor l_get_address Is
Select  arp_addr_label_pkg.format_address (NULL,l.address1,l.address2,
                                          l.address3,l.address4,l.city,l.county,
                                          l.state,l.province,l.postal_code,
                                          NULL,l.country,NULL,NULL,NULL,NULL,
                                          NULL,NULL,NULL,'N','N',300,1,1)
From hz_cust_site_uses_all cs
           ,hz_party_sites ps
           ,hz_locations l
Where cs.site_use_id (+) = p_site_use_id
AND cs.cust_acct_site_id = ps.party_site_id(+)
AND ps.location_id = l.location_id(+);
l_address Varchar2(4000);
Begin
Open l_get_address;
Fetch l_get_address into l_address;
Close l_get_address;

return(l_address);


End;

Procedure get_srv_name(P_line_id  Number, x_service_name Out NoCopy  Varchar2, x_service_description Out NoCopy varchar2) Is

Cursor get_name_csr Is
Select fnd_flex_server.get_kfv_concat_segs_by_rowid('COMPACT', 401, 'SERV', 101,  mtl.rowid), description
From Mtl_system_items_b mtl
     , okc_k_items itm
Where mtl.inventory_item_id = itm.object1_id1
and  mtl.organization_id = itm.object1_id2
And  itm.cle_id = p_line_id;


Begin
Open get_name_csr;
Fetch get_name_csr into x_service_name, x_service_description;
Close get_name_csr;

End;


FUNCTION get_covlvl_name
(
p_jtot_code    IN VARCHAR2,
p_object1_id1  IN VARCHAR2,
p_object1_id2  IN VARCHAR2
)
RETURN VARCHAR2

IS
l_name VARCHAR2(2000);
l_chr_id  NUMBER;

CURSOR get_prod_name_csr IS
SELECT mtl.concatenated_segments
From   mtl_system_items_kfv mtl,
       okc_k_items_v itm
       ,csi_item_instances csi
where itm.object1_id1 = p_object1_id1
And   itm.jtot_object1_code = 'OKX_CUSTPROD'
And   csi.instance_id = itm.object1_id1
And   csi.inventory_item_id = mtl.inventory_item_id
And rownum < 2;

CURSOR get_site_name_csr IS
SELECT DECODE(site.party_site_name
               ,NULL,site.party_site_number
               ,site.party_site_number || '-' ||
               site.party_site_name  ) NAME
FROM      hz_party_sites site
WHERE  site.party_site_id = p_object1_id1;

BEGIN
l_name  :=      okc_util.get_name_from_jtfv(p_jtot_code,p_object1_id1,p_object1_id2);

IF ( p_jtot_code= ('OKX_COVITEM')
    OR p_jtot_code = ('OKX_SERVICE'))
THEN
  okc_context.set_okc_org_context(NULL, p_object1_id2);
  l_name  :=      okc_util.get_name_from_jtfv(p_jtot_code,p_object1_id1,p_object1_id2);

ELSIF  p_jtot_code= ('OKX_PARTYSITE')
THEN
           Open get_site_name_csr;
           Fetch get_site_name_csr into l_name ;
           Close get_site_name_csr;

ELSIF p_jtot_code = ('OKX_CUSTPROD')
THEN
           Open get_prod_name_csr;
           Fetch get_prod_name_csr into l_name ;
           Close get_prod_name_csr;

ELSE
  l_name  :=      okc_util.get_name_from_jtfv(p_jtot_code,p_object1_id1,p_object1_id2);
END IF;

RETURN (l_name);
END;


  End OKS_IB_UTIL_PVT;

/
