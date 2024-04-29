--------------------------------------------------------
--  DDL for Package Body JAI_AP_MISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_MISC_PKG" AS
/*  $Header: jai_ap_misc_pkg.plb 120.2.12000000.1 2007/10/24 18:20:13 rallamse noship $ */

procedure jai_calc_ipv_erv (P_errmsg OUT NOCOPY VARCHAR2,
                            P_retcode OUT NOCOPY Number,
          P_invoice_id in number,
          P_po_dist_id in number,
          P_invoice_distribution_id IN NUMBER,
          P_amount IN NUMBER,
          P_base_amount IN NUMBER,
          P_rcv_transaction_id IN NUMBER,
          P_invoice_price_variance IN NUMBER,
          P_base_invoice_price_variance IN NUMBER,
          P_price_var_ccid IN NUMBER,
          P_Exchange_rate_variance IN NUMBER,
          P_rate_var_ccid IN NUMBER
                           )
as

/* Cursors  */

Cursor check_rec_tax ( ln_tax_id number) is
select tax_name,
        tax_account_id,
        mod_cr_percentage,
        adhoc_flag,
        nvl(tax_rate, 0) tax_rate,
        tax_type
from  JAI_CMN_TAXES_ALL
where  tax_id = ln_tax_id;


Cursor get_misc_lines (ln_dist_line_number in number,
                       ln_invoice_id in number ) is
select *
  from ap_invoice_distributions_all
 where invoice_id = ln_invoice_id
   and distribution_line_number = ln_dist_line_number;


/* precision */
Cursor get_prec (lv_currency_code varchar2) is
select precision
from  fnd_currencies
where currency_code = lv_currency_code;


/* Local Variables */
ln_tax_ipv number;
ln_tax_bipv number;
ln_price_var_ccid number;

ln_tax_erv number;

lv_inv_curr_code varchar2(15);
lv_base_curr_code varchar2(15);

ln_inv_pre number;
ln_base_pre number;

r_get_misc_lines get_misc_lines%ROWTYPE;



Begin


   fnd_file.put_line(FND_FILE.LOG, ' inside procedure ');

   lv_base_curr_code := 'INR';

   Begin
     Select invoice_currency_code
       into lv_inv_curr_code
       from ap_invoices_all
      where invoice_id = p_invoice_id;

   Exception
      When others then
        null;
   End;

   If lv_inv_curr_code = 'INR' Then
     open get_prec(lv_base_curr_code);
      Fetch get_prec into ln_base_pre;
     Close get_prec;

     ln_inv_pre := ln_base_pre;

   Else
     open get_prec(lv_inv_curr_code);
      Fetch get_prec into ln_inv_pre;
     Close get_prec;

     open get_prec(lv_base_curr_code);
      Fetch get_prec into ln_base_pre;
     Close get_prec;

   End if;

   fnd_file.put_line(FND_FILE.LOG, ' invoice id '|| p_invoice_id);
   fnd_file.put_line(FND_FILE.LOG, ' po dist  id '|| p_po_dist_id);

   for Misc_loop in ( select *
                          from JAI_AP_MATCH_INV_TAXES
                         where invoice_id = p_invoice_id
         and parent_invoice_distribution_id = p_invoice_distribution_id
                      )
     loop


       fnd_file.put_line(FND_FILE.LOG,' inside loop -- 2 ' );

       /* For later use if necessary to check the tax type. now education cess will not be
     created at invoice level if it is available in PO/Receipt level

         for tax_loop in check_rec_tax (select tax_id
             from JAI_AP_MATCH_INV_TAXES
                 where invoice_id = misc_loop.invoice_id
              and distribution_line_number = misc_loop.distribution_line_number)
         loop

         Service and Education cess are recoverable taxes and
         IPV should not be calculated on these lines
      If  not (tax_loop.tax_type like '%EDUCATION_CESS') Then

       */

       Open get_misc_lines(misc_loop.distribution_line_number, misc_loop.invoice_id);
         Fetch get_misc_lines into r_get_misc_lines;
       Close get_misc_lines;

       If nvl(p_amount ,0) <> 0 Then

         fnd_file.put_line(FND_FILE.LOG,' Inside item amount not zero ' || p_amount);

         If nvl(r_get_misc_lines.amount , 0 ) <> 0 Then

         fnd_file.put_line(FND_FILE.LOG,' Inside Tax amount not zero ' || r_get_misc_lines.amount);

   IF nvl(p_invoice_price_variance,0 ) <> 0 Then

           ln_tax_ipv := r_get_misc_lines.amount * (nvl(p_invoice_price_variance,0) /p_amount);

         End if;

   IF nvl(p_exchange_rate_variance,0 ) <> 0 Then

           ln_tax_erv := r_get_misc_lines.amount * (nvl(p_exchange_rate_variance,0)/p_amount);

         End if;

         fnd_file.put_line(FND_FILE.LOG,' IPV '|| ln_tax_ipv);
         fnd_file.put_line(FND_FILE.LOG,' ERV '|| ln_tax_erv);

         /* IPV */

         If nvl(ln_tax_ipv,0) <> 0   then

          fnd_file.put_line(FND_FILE.LOG,' Inside IPV not zero '|| ln_tax_ipv);

           ln_tax_bipv := ln_tax_ipv * nvl(r_get_misc_lines.exchange_rate,1);

                 update ap_invoice_distributions_all
                    set invoice_price_variance = round(ln_tax_ipv,ln_inv_pre),
                         base_invoice_price_variance = round(ln_tax_bipv, ln_base_pre),
                         price_var_code_combination_id = P_price_var_ccid
                  where invoice_distribution_id = r_get_misc_lines.invoice_distribution_id;
         End if;

         /* ERV */


         If nvl(ln_tax_erv,0) <> 0   then

          fnd_file.put_line(FND_FILE.LOG,' Inside ERV not zero '|| ln_tax_erv);
          fnd_file.put_line(FND_FILE.LOG,' rate var CCID '|| P_rate_var_ccid);

                 update ap_invoice_distributions_all
                    set exchange_rate_variance = round(ln_tax_erv,ln_inv_pre),
                        rate_var_code_combination_id = P_rate_var_ccid
                  where invoice_distribution_id = r_get_misc_lines.invoice_distribution_id;
        End if;


        Else

         /* update ipv and bipv to 0. no need to update Var CCID */

               update ap_invoice_distributions_all
                    set invoice_price_variance = 0,
                        base_invoice_price_variance = 0,
      exchange_rate_variance = 0
               where invoice_distribution_id = r_get_misc_lines.invoice_distribution_id;
         End if;
   /*  r_get_misc_lines.amount <> 0  */

        End if; /* p_amount <> 0 */

       -- end loop;  -- End tax_loop
     end loop;       -- End misc_loop

   p_errmsg :=NULL;
   p_retcode := NULL;


Exception
  When others then
      P_errmsg := SQLERRM;
      P_retcode := 2;
      Fnd_File.put_line(Fnd_File.LOG, 'EXCEPTION END PROCEDURE - JAI_CALC_IPV ');
      Fnd_File.put_line(Fnd_File.LOG, 'Error : ' || P_errmsg);
End jai_calc_ipv_erv;

-- added, Harshita for Bug 5553150

FUNCTION fetch_tax_target_amt
( p_invoice_id          IN NUMBER      ,
  p_line_location_id    IN NUMBER ,
  p_transaction_id      IN NUMBER ,
  p_parent_dist_id      IN NUMBER,
  p_tax_id              IN NUMBER
)
RETURN NUMBER
IS

  TYPE TAX_CUR IS RECORD
  (
    P_1   JAI_PO_TAXES.precedence_1%type,
    P_2   JAI_PO_TAXES.precedence_2%type,
    P_3   JAI_PO_TAXES.precedence_3%type,
    P_4   JAI_PO_TAXES.precedence_4%type,
    P_5   JAI_PO_TAXES.precedence_5%type,
    P_6   JAI_PO_TAXES.precedence_6%type,
    P_7   JAI_PO_TAXES.precedence_7%type,
    P_8   JAI_PO_TAXES.precedence_8%type,
    P_9   JAI_PO_TAXES.precedence_9%type,
    P_10  JAI_PO_TAXES.precedence_10%type
   ) ;

   TYPE tax_cur_type IS REF CURSOR RETURN TAX_CUR;
   c_tax_cur TAX_CUR_TYPE;
   rec     c_tax_cur%ROWTYPE;
   ln_base_amt number ;


    FUNCTION fetch_line_amt(p_precedence_value IN NUMBER)
    RETURN NUMBER
    IS
      cursor c_line_amt
      is
      select NVL(SUM(tax_amount),-1)  -- 5763527, Added SUM as partially recoverable taxes will have two lines
      from JAI_AP_MATCH_INV_TAXES
      where invoice_id = p_invoice_id
      and   line_no = p_precedence_value ;

      cursor c_base_inv_amt
      is
      select amount
      from ap_invoice_distributions_all
      where  invoice_distribution_id = p_parent_dist_id
      and invoice_id = p_invoice_id ;

      ln_line_amt number ;

    BEGIN
      if p_precedence_value = -1 then
        return 0 ;
      elsif p_precedence_value = 0 then
        open c_base_inv_amt ;
        fetch c_base_inv_amt into ln_line_amt ;
        close c_base_inv_amt ;
        return nvl(ln_line_amt,0) ;
      else
        open c_line_amt ;
        fetch c_line_amt into ln_line_amt ;
        close c_line_amt ;
        return nvl(ln_line_amt,0) ;
      end if ;

    END fetch_line_amt;

  BEGIN

    IF p_line_location_id is not null then
      OPEN c_tax_cur FOR
      select Precedence_1 P_1,
             Precedence_2 P_2,
             Precedence_3 P_3,
             Precedence_4 P_4,
             Precedence_5 P_5,
             Precedence_6 P_6,
             Precedence_7 P_7,
             Precedence_8 P_8,
             Precedence_9 P_9,
             Precedence_10 P_10
     from JAI_PO_TAXES
     where line_location_id = p_line_location_id
     and tax_id = p_tax_id ;
    ELSE
      OPEN c_tax_cur FOR
      select Precedence_1 P_1,
             Precedence_2 P_2,
             Precedence_3 P_3,
             Precedence_4 P_4,
             Precedence_5 P_5,
             Precedence_6 P_6,
             Precedence_7 P_7,
             Precedence_8 P_8,
             Precedence_9 P_9,
             Precedence_10 P_10
     from JAI_RCV_LINE_TAXES
     where shipment_line_id IN
           ( select shipment_line_id
             from JAI_RCV_TRANSACTIONS
             where  transaction_id = p_transaction_id
           )
     and tax_id = p_tax_id ;

    END IF ;

    FETCH c_tax_cur INTO rec;
      ln_base_amt  := fetch_line_amt(nvl(rec.P_1,-1))  + fetch_line_amt(nvl(rec.P_2,-1))
                      + fetch_line_amt(nvl(rec.P_3,-1)) + fetch_line_amt(nvl(rec.P_4,-1))
                      + fetch_line_amt(nvl(rec.P_5,-1)) + fetch_line_amt(nvl(rec.P_6,-1))
                      + fetch_line_amt(nvl(rec.P_7,-1)) + fetch_line_amt(nvl(rec.P_8,-1))
                      + fetch_line_amt(nvl(rec.P_9,-1)) + fetch_line_amt(nvl(rec.P_10,-1));
    CLOSE c_tax_cur ;
    return ln_base_amt ;


  END fetch_tax_target_amt ;
  -- ended, Harshita for Bug 5553150

End JAI_AP_MISC_PKG;

/
