--------------------------------------------------------
--  DDL for Package Body PA_CMT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CMT_UTILS" AS
/* $Header: PAXCMTUB.pls 120.20 2008/06/12 11:02:42 byeturi ship $ */
g_accrue_on_receipt_flag varchar2(1);  /*bug 5946201*/
/* Function : get_rcpt_qty
   Return   : Returns the commitment quantity not yet interfaced to PA
   IN parameters: PO Distribution Id,
                  PO Distribution's Qty Ordered,
                  PO Distribution's Qty Canceled,
                  PO Distribution's Qty Billed and
                  Calling module :  PO or AP
   Logic:
         If called from the PO view, the function first retrieves the total
         receipt quantity already interfaced to PA.  If the receipt qty is 0 then the
         total PO commitment quantity is equal to (qty ordered - qty canceled - qty billed).
         If receipt quantity is greater than 0 then the greatest of receipt quantity and qty billed
         will be subtracted from the total PO quantity (qty ordered - qty canceled)
         If called from the AP view, the total quantity invoiced (pa_quantity)  and number of invoice
         distributions created for a specific PO distribution is selected. If the receipt quantity is
         0 then quantity invoiced equals the total invoice quantity divided by the number of invoices.
         If receipt quantity greater than 0 then the greatest of receipt quantity and total invoice
         quantity is distributed to the number of invoices.
*/

FUNCTION get_rcpt_qty(p_po_dist in number,
                      p_qty_ordered in number,
                      p_qty_cancel in number,
                      p_qty_billed in number,
                      p_module in varchar2,
                      --Pa.M Added below parameters
                      p_po_line_id in number,
                      p_project_id in number,
                      p_task_id in number,
                      p_ccid in number,
                      -- Bug 3556021 : Added for retroactive price adjustment
                      p_pa_quantity IN NUMBER,
                      p_inv_source  IN VARCHAR2,
                      p_line_type_lookup_code IN VARCHAR2 ,
                      p_matching_basis in VARCHAR2 default null, -- Bug 3642604
                      p_nrtax_amt in number default null, -- Bug 3642604
				  P_CASH_BASIS_ACCTG in varchar2 default 'N',
                      p_accrue_on_receipt_flag  IN varchar2 default NULL /* Bug 5014034 */
                      ) RETURN NUMBER
IS
    l_rcpt_qty number;
    l_inv_num  number;
    l_tot_inv_qty  number;

    --Pa.M
    L_RateBasedPO  Varchar2(1);
    L_CWKTCXface   Varchar2(1);
    L_EiCost       Number;
    l_PoLineCosts       Number;
    l_RcptNrTaxCosts    Number;
    l_PoLineDistCnt     Number;
    l_PoLineDistCosts   Number;
    l_calc_ap_tax       Number ;
    l_qty_billed        NUMBER ;

    l_FoundFlag    Varchar2(1) := 'N';
    l_Index        Number;

BEGIN

 -- R12 change for cash basis accounting.

    --dbms_output.put_line('qty_ordered = ' || p_qty_ordered);
    --dbms_output.put_line('qty_cancel = ' || p_qty_cancel);
    --dbms_output.put_line('qty_billed = ' || p_qty_billed);

    --  Bug 3556021 : When fired for AP Invoice this function will return
    --  zero for TAX and PO price adjustment lines.
    l_qty_billed  := p_qty_billed ;

    IF ( p_module = 'AP' AND (NVL(p_inv_source,'X') ='PPA' OR p_line_type_lookup_code = 'TAX')) THEN
       return 0;
    END IF;

    IF p_accrue_on_receipt_flag = 'Y' and l_qty_billed <> 0 THEN

       -- Bug    : 5014034
       -- Isssue : R12 functionality would interface receipts for accrue on receipt PO and
       --          variance would interface from supplier invoice which was matched to a
       --          accrue on receipt PO.
       --
       --          Supplier cost interface process marks the invoice distribution with pa_addition_flag value 'G'
       --          to indicate receipt would interface for such distributions.
       --          PSI do not shows invoice distributions that has pa_addition_flag value 'G'
       -- Resolution
       --          Fix under this bug is making sure that PO commitments are not reduced in PSI corresponding to
       --          qty billed amount updated as part of PO match in Supplier invoice.
       --          Quantity billed is not considered for accrue on receipt PO because invoice distributions are not
       --          elligible for interface.
       --          We are only considering qty billed for historical transactions that has pa addition flag value 'Y'.
       --

       select sum(apd.quantity_invoiced)
         into l_qty_billed
         from po_distributions_all pod,
              ap_invoice_distributions_all apd
        where pod.po_distribution_id              = p_po_dist
          and pod.po_distribution_id              = apd.po_distribution_id
          and NVL(pod.accrue_on_receipt_flag,'N') = 'Y'
          and apd.pa_addition_flag                = 'Y'
          and apd.line_type_lookup_code           in ( 'ACCRUAL', 'ITEM', 'PREPAY', 'NONREC_TAX' )
          and nvl(apd.quantity_invoiced,0)        <> 0 ;

       l_qty_billed := NVL(l_qty_billed,0) ;

    END IF ;

    --PA.M
    L_RateBasedPO :=  Pa_Pjc_Cwk_Utils.Is_Rate_Based_Line(p_po_line_id, null);
    L_CWKTCXface :=  Pa_Pjc_Cwk_Utils.Is_Cwk_TC_Xface_Allowed(P_Project_Id);

    If L_RateBasedPO = 'Y' and L_CWKTCXface = 'Y' Then ---{

       l_FoundFlag := 'N';

       IF G_CommCostTab.count > 0 THEN

          FOR j in G_CommCostTab.first..G_CommCostTab.LAST LOOP

              IF G_CommCostTab(j).project_id = p_project_id and
                 G_CommCostTab(j).task_id = p_task_id and
                 G_CommCostTab(j).po_line_id = p_po_line_id THEN

                 l_FoundFlag := 'Y';

                 l_PoLineCosts := nvl(G_CommCostTab(j).commcosts,0);

             END IF;

          END LOOP;

       END IF;

  /* If cash basis accounting is implemented then receipts are not interfaced to PA */
     IF P_CASH_BASIS_ACCTG = 'N' THEN --R12 change ------{
       Select nvl(Sum(nvl(ENTERED_NR_TAX,0)),0)
         Into l_RcptNrTaxCosts
         from rcv_transactions a,   rcv_receiving_sub_ledger c
        where a.po_distribution_id = p_po_dist
         and ((a.destination_type_code = 'EXPENSE' ) or
             (a.destination_type_code = 'RECEIVING' and
              a.transaction_type in ('RETURN TO RECEIVING' , 'RETURN TO VENDOR')))
         and c.pa_addition_flag = 'Y'
         and c.rcv_transaction_id = a.transaction_id
         and c.code_combination_id = p_ccid
         and c.actual_flag = 'A';
      END IF;

       -- If NRTAX has been interfaced as receipts then we will not deduct the AP nrtax else it will be deducted twice
       -- Calculate the AP tax only if Receipt tax is zero
       If l_RcptNrTaxCosts = 0 Then
          l_calc_ap_tax := 1;
       Else
          l_calc_ap_tax := 0;
       End If;

       If l_FoundFlag = 'N' Then

          --Commitment Costs = ((Sum of PO Dist Costs for Proj/Task and Po Line) -
          --                      (Sum of distributed EI Costs) -
          --                      (Sum of NRTax interfaced to PA as receipts or supplier costs))

          --Get sum of all EI Costs for the Project, Task and Po Line Id
 /*         select sum(nvl(denom_raw_cost,0))
            into l_EiCost
            from pa_expenditure_items_all ei
           where ei.project_id = p_project_id
             and ei.task_id = p_task_id
             and ei.po_line_id = p_po_line_id
             and cost_distributed_flag = 'Y';
*/

            -- Bug 4093917 : Modified the EI query to retrieve cost from CDL so incase the EI is marked for recosting, po cmt is not again considered
            -- Bug 6979249: since we are summing all EI Costs based on project,Task and Po Line Id hence PO Projects PSI Commitment are not getting relieved .
	    -- so commented the project and task conditions  to releive Po project PSI commitment.
            Select sum(nvl(cdl.denom_raw_cost,0))
            into   l_EiCost
            from   pa_cost_distribution_lines_all cdl
                 , pa_expenditure_items_all ei
            where  cdl.expenditure_item_id = ei.expenditure_item_id
           /* and    ei.project_id = p_project_id
            and    ei.task_id = p_task_id commented for bug:6979249*/
            and    ei.po_line_id = p_po_line_id;


          -- Bug 3529107 : Modified the below code such that PSI shows rate based PO's amount
          -- without subtracting the billed amount which is not eligible for interface to PA.
          -- i.e.Amount on PO = (Amount ordered)-(Amount canceled) - (Interfaced distributed
          -- Expenditure Costs) - (NRTAX interfaced to PA as supplier cost or receipts)

          Select count(*), Sum(nvl(Amount_Ordered,0) + nvl(NonRecoverable_Tax,0) - nvl(Amount_Cancelled,0) -
                               ((nvl(NonRecoverable_Tax,0) * nvl(amount_billed,0) / nvl(amount_ordered,1)) * l_calc_ap_tax)
                              )
            Into l_PoLineDistCnt, l_PoLineDistCosts
            From Po_Distributions_All Pod
           Where Pod.Project_Id = P_Project_Id
             And Pod.distribution_type <> 'PREPAYMENT'
             And Pod.Task_Id = P_Task_Id
             And Pod.Po_Line_Id = P_Po_Line_Id;

          l_PoLineCosts := nvl(((nvl(l_PoLineDistCosts,0)/nvl(l_PoLineDistCnt,1)) - (nvl(l_EiCost,0)/nvl(l_PoLineDistCnt,1))),0);

          l_index := G_CommCostTab.Count + 1;

          G_CommCostTab(l_index).project_id := p_project_id;
          G_CommCostTab(l_index).task_id := p_task_id;
          G_CommCostTab(l_index).po_line_id := p_po_line_id;
          G_CommCostTab(l_index).commcosts := l_PoLineCosts;

       End If;


       -- Deduct the Receipt tax only if tax has been interfaced as receipt
       If l_calc_ap_tax = 0 Then
         L_Rcpt_Qty := Greatest(0, (l_PoLineCosts - nvl(l_RcptNrTaxCosts,0) ));
       Else
         L_Rcpt_Qty := Greatest(0, l_PoLineCosts);
       End if;

    Else


  /* If cash basis accounting is implemented then receipts are not interfaced to PA */
     IF P_CASH_BASIS_ACCTG = 'N' THEN --R12 change ------{

/*Added for bug#6408874 - START */

        IF ( (nvl(g_po_distr_id,-999) = nvl(p_po_dist,-999)) AND
              (nvl(g_qty_ordered,-999) = nvl(p_qty_ordered,-999)) AND
              (nvl(g_qty_cancel,-999) = nvl(p_qty_cancel,-999)) AND
              (nvl(g_qty_billed,-999) = nvl(l_qty_billed,-999)) AND -- Changed to l_quantity_billed
              (nvl(g_module,'XSDD') = nvl(p_module,'XSDD')) AND
              (nvl(g_pa_quantity,-999) = nvl(p_pa_quantity,-999)) AND
              (nvl(g_inv_source,'XSDD') = nvl(p_inv_source,'XSDD')) AND
              (nvl(g_line_type_lookup_code,'XSDD') = nvl(p_line_type_lookup_code,'XSDD'))
            ) THEN
         return g_rcpt_qty;
         ELSE
           g_po_distr_id := p_po_dist;
           g_qty_ordered := p_qty_ordered;
           g_qty_cancel  := p_qty_cancel;
           g_qty_billed  := l_qty_billed; -- Changed to l_quantity_billed
           g_module      := p_module;
           g_pa_quantity := p_pa_quantity;
           g_inv_source  := p_inv_source;
           g_line_type_lookup_code := p_line_type_lookup_code;
         END IF;

/*Added for bug#6408874 - END */

   IF nvl(p_matching_basis,'QUANTITY') = 'AMOUNT' THEN /* modified for bug bug 3496492 */

/* This is an amount based PO and so quantity will be the same as the amount */

/* Added index hint as part of bug 6408874 */
     select /*+ Index(c RCV_RECEIVING_SUB_LEDGER_N1) */sum(decode(a.destination_type_code,
                              'EXPENSE',
                              decode(transaction_type,
                                     'RETURN TO RECEIVING',
                                      -1 * (decode(c.pa_addition_flag,
                                                   'Y',
                                                   (nvl(c.entered_dr,0)-nvl(c.entered_cr,0)),
                                                   'I',
                                                   (nvl(c.entered_dr,0)-nvl(c.entered_cr,0)-nvl(c.entered_nr_tax,0)))),
                                           (decode(c.pa_addition_flag,
                                                   'Y',
                                                   (nvl(c.entered_dr,0)-nvl(c.entered_cr,0)),
                                                   'I',
                                                   (nvl(c.entered_dr,0)-nvl(c.entered_cr,0)-nvl(c.entered_nr_tax,0))))),
                               'RECEIVING',
                               -1 * (decode(c.pa_addition_flag,
                                            'Y',
                                            (nvl(c.entered_dr,0)-nvl(c.entered_cr,0)),
                                            'I',
                                            (nvl(c.entered_dr,0)-nvl(c.entered_cr,0)-nvl(c.entered_nr_tax,0))))))
      into l_rcpt_qty
      from rcv_transactions a,
           rcv_receiving_sub_ledger c
      where a.po_distribution_id = p_po_dist
      and ((a.destination_type_code = 'EXPENSE') or
        (a.destination_type_code = 'RECEIVING' and
         a.transaction_type in ('RETURN TO RECEIVING' , 'RETURN TO VENDOR')))
      and c.pa_addition_flag in ('Y', 'I')
      and c.rcv_transaction_id = a.transaction_id
      and c.actual_flag = 'A';

    ELSE

       /*bug 5946201 - We need a specific SELECT for eIB items for reason mentioned in the bug*/
      IF (Is_eIB_item(p_po_dist) = 'Y' AND g_accrue_on_receipt_flag = 'N') THEN

 	         select sum(decode(destination_type_code, 'EXPENSE', decode(transaction_type,'RETURN TO RECEIVING',-1 * quantity, quantity),'RECEIVING',-1 * quantity))
 	         into l_rcpt_qty
 	         from rcv_transactions a
 	         where a.po_distribution_id = p_po_dist
 	         and ((a.destination_type_code = 'EXPENSE' ) or
 	                 (a.destination_type_code = 'RECEIVING' and a.transaction_type in ('RETURN TO RECEIVING' , 'RETURN TO VENDOR')))
 	         and  a.pa_addition_flag in ('Y','I') ;

      ELSE /* for 1.all eIB items with accrue at receipt checked and 2.All non-eIB items existing  SELECT is fine  */
/* Added index hint as part of bug 6408874 */

		select sum(decode(destination_type_code,
                              'EXPENSE',
                              decode(transaction_type,
                                          'RETURN TO RECEIVING',
                                          -1 * quantity,
                                          quantity),
                               'RECEIVING',
                               -1 * quantity))
		into l_rcpt_qty
		from rcv_transactions a
		where a.po_distribution_id = p_po_dist
		and ((a.destination_type_code = 'EXPENSE' ) or
		(a.destination_type_code = 'RECEIVING' and
		a.transaction_type in ('RETURN TO RECEIVING' , 'RETURN TO VENDOR')))
    and EXISTS ( SELECT /*+ Index(rcv_sub RCV_RECEIVING_SUB_LEDGER_N1) */ rcv_sub.rcv_transaction_id
		FROM rcv_receiving_sub_ledger rcv_sub
		WHERE rcv_sub.rcv_transaction_id = a.transaction_id
		AND rcv_sub.pa_addition_flag in ('Y', 'I'));
      END IF; /* IF is_eib_item...*/
    END IF;
   END IF; --Cash basis accounting.  -----}
    --dbms_output.put_line('rcpt after select = ' || nvl(l_rcpt_qty,0));

    --                instead of average .And during calculation of logic donot consider
    --                TAX,PO PRICE ADJUSTed lines.

    if (nvl(l_rcpt_qty,0) = 0) then
       --dbms_output.put_line('rcpt qty = 0');
       if (p_module = 'PO') then
          if nvl(p_matching_basis,'QUANTITY') = 'AMOUNT' then -- Bug 3642604
            l_rcpt_qty := p_qty_ordered + p_nrtax_amt - p_qty_cancel- l_qty_billed - (p_nrtax_amt * l_qty_billed/nvl(p_qty_ordered,1));
          else
            l_rcpt_qty := p_qty_ordered-p_qty_cancel-l_qty_billed;
          end if;
          --dbms_output.put_line('rcpt qty 0 and PO = ' || nvl(l_rcpt_qty,0));
       elsif (p_module = 'AP') then
          l_rcpt_qty := p_pa_quantity ; --l_tot_inv_qty/l_inv_num; -- Bug 3556021
          --dbms_output.put_line('rcpt qty 0 and AP = ' || nvl(l_rcpt_qty,0));
       end if;
       g_rcpt_qty := l_rcpt_qty; -- Added for Bug#6408874
       return l_rcpt_qty;
    end if;

    if (p_module = 'PO') then
       --dbms_output.put_line('calling = PO ');
       if nvl(p_matching_basis,'QUANTITY') = 'AMOUNT' then -- Bug 3642604
         l_rcpt_qty := p_qty_ordered + p_nrtax_amt -p_qty_cancel-greatest(((l_qty_billed + (p_nrtax_amt * l_qty_billed/nvl(p_qty_ordered,1))) -l_rcpt_qty),0)-l_rcpt_qty ;
       else
         l_rcpt_qty := p_qty_ordered -p_qty_cancel-greatest((l_qty_billed-l_rcpt_qty),0)-l_rcpt_qty ;
       end if;
       --dbms_output.put_line('rcpt in PO = '||l_rcpt_qty);
    elsif (p_module = 'AP') then
       --dbms_output.put_line('calling = AP ');

  -- R12 change
     IF P_CASH_BASIS_ACCTG = 'Y' THEN --R12 change ------{

      -- For each PO distribution, take the total payment amount, and prorate it invoice distribution
      -- amount and quantity

       select count(*),
             SUM(dist.pa_quantity*(SUM(nvl(paydist.paid_base_amount,paydist.amount))/(nvl(dist.base_amount,dist.amount))))
       into  l_inv_num, l_tot_inv_qty
       from  ap_invoice_distributions_all dist,
             ap_payment_hist_dists paydist,
             ap_invoices_all inv
       where dist.po_distribution_id = p_po_dist
       and   dist.charge_applicable_to_dist_id is null  --R12 change
       and   dist.related_id is null -- R12 change
       and   dist. line_type_lookup_code <> 'REC_TAX'
       and   paydist.pa_addition_flag ='N'
       and   inv.invoice_id = dist.invoice_id
       and   dist.invoice_distribution_id = paydist.invoice_distribution_id
       and   NVL(inv.source,'X') <> 'PPA'
       --    4905546
       --    ap_payment_hist_dists has discounts and cash records. we need to include quantity
       --    only for the payment otherwise quantity would double because of discount.
       --    adding the criteria to filter discounts for payment.
       and   paydist.pay_dist_lookup_code = 'CASH'
       group by dist.invoice_distribution_id,NVL(dist.base_amount,dist.amount), dist.pa_quantity;

       l_rcpt_qty := greatest(0,greatest((l_tot_inv_qty),0)/l_inv_num);

     ELSE
       select count(*), sum(dist.pa_quantity)
       into  l_inv_num, l_tot_inv_qty
       from  ap_invoice_distributions_all dist,
             ap_invoices_all inv
       where dist.po_distribution_id = p_po_dist
       -- and   dist.line_type_lookup_code = 'ITEM' --R12 change
       and   dist. line_type_lookup_code <> 'REC_TAX'
       and   nvl(reversal_flag,'N') <> 'Y' /* Bug 5673779 */
       and   dist.charge_applicable_to_dist_id is null --R12 change
       and   dist.related_id is null --R12 change
       and   dist.pa_addition_flag not in ('Z','T','E','Y')  /** Added for bug 3167288 **/
       and   inv.invoice_id = dist.invoice_id                -- Bug 3556021
       and   NVL(inv.source,'X') <> 'PPA';                   -- Bug 3556021

       --dbms_output.put_line('no. of invoices = ' || nvl(l_inv_num,0));
       --dbms_output.put_line('total inv amount = ' || nvl(l_tot_inv_qty,0));

       l_rcpt_qty := greatest(0,greatest((l_tot_inv_qty-l_rcpt_qty),0)/l_inv_num);
       --dbms_output.put_line('rcpt in AP= '||l_rcpt_qty);
     END IF; -----------------}
    end if;

   End If;  ---}

   g_rcpt_qty := l_rcpt_qty; -- Added for Bug#6408874
   return l_rcpt_qty;

EXCEPTION
   when no_data_found then
--        null; Bug 3864527
        return 0;
END get_rcpt_qty;

/* Function : get_inv_cmt
   Return   : This function returns the invoice amount not yet interfaced to PA
              taking into consideration the receipt amount interfaced to PA.
   IN parameters: PO Distribution Id,
                  Denom Amt Flag   : To distinguish transaction and functional amount
                  PA Addition Flag : Invoice Distribution's pa_addition_flag
                  Variance Amount  : Total of invoice_proce_variance and exchange_rate_variance
                  Calling module   : PO or AP, but used mainly for AP currently.
   Logic:
         If called from the AP view, first the receipt amount interfaced to PA is selected.
         Then the invoice amount omiting the variances is selected in addition to the number
         of invoice created for a given po distribution.
         If the pa_addition_flag is 'F', meaning the variance amount has been interfaced to PA
         then the variance amount is not considered as a commitment, else it is considered for
         AP commitment.
         The AP commitment is calculated as the invoice amount excluding the variance, receipt
         amount. And then we add the variance if it has not yet been transferred to PA.
         Since its hard to figure out which receipt matches to which invoice, we always divide
         the total invoice amount exculding the receipt amount by the number of invoices
         created for a po distribution.
*/

FUNCTION get_inv_cmt(p_po_dist in number,
                     p_denom_amt_flag in varchar2,
                     p_pa_add_flag in varchar2,
                     p_var_amt in number,
                     p_ccid in number,
                     p_module in varchar2,
                     p_invoice_id       in number DEFAULT NULL ,        /* Added for Bug 3394153 */
                     p_dist_line_num    in number DEFAULT NULL,         /* Added for Bug 3394153 */
                     p_inv_dist_id      in number DEFAULT NULL,         /* Added for Bug 3394153 */
				 P_CASH_BASIS_ACCTG varchar2 default 'N'
				 ) RETURN NUMBER
IS
    l_rcpt_amt number;
    l_inv_num  number;
    l_inv_amt  number;
    l_var_amt  number;

BEGIN

IF P_CASH_BASIS_ACCTG = 'N' THEN  --R12 change --------{
    --pricing changes start
    IF (p_denom_amt_flag <> 'Y') THEN
    select sum(decode(c.pa_addition_flag, 'Y', (nvl(accounted_dr,0)-nvl(accounted_cr,0)),
                                          'I', ((nvl(accounted_dr,0)-nvl(accounted_cr,0))-(nvl(accounted_nr_tax,0))
                                                )))
    into l_rcpt_amt
    from rcv_transactions a,   rcv_receiving_sub_ledger c
    where a.po_distribution_id = p_po_dist
    and ((a.destination_type_code = 'EXPENSE' ) or
        (a.destination_type_code = 'RECEIVING' and
         a.transaction_type in ('RETURN TO RECEIVING' , 'RETURN TO VENDOR')))
    and c.pa_addition_flag in ('Y', 'I')
    and c.rcv_transaction_id = a.transaction_id
    and c.code_combination_id = p_ccid
    and c.actual_flag = 'A';

    ELSE
    select sum(decode(c.pa_addition_flag, 'Y', (nvl(entered_dr,0)-nvl(entered_cr,0)),
                                          'I', ((nvl(entered_dr,0)-nvl(entered_cr,0))-(nvl(entered_nr_tax,0))
                                                )))
    into l_rcpt_amt
    from rcv_transactions a,   rcv_receiving_sub_ledger c
    where a.po_distribution_id = p_po_dist
    and ((a.destination_type_code = 'EXPENSE' ) or
        (a.destination_type_code = 'RECEIVING' and
         a.transaction_type in ('RETURN TO RECEIVING' , 'RETURN TO VENDOR')))
    and c.pa_addition_flag in ('Y', 'I')
    and c.rcv_transaction_id = a.transaction_id
    and c.code_combination_id = p_ccid
    and c.actual_flag = 'A';
    END IF;
 END IF; --R12 change ----------------------------------}
    --pricing changes end
    --dbms_output.put_line('rcpt after select = ' || nvl(l_rcpt_amt,0));

    /* Bug 3394153 : If there are no receipts(matched to PO) interfaced to Projects then
       this function returns the actual commitment amount for each invoice.
       If there are receipts interfaced then since the invoices can never be transferred
       to Projects we would continue with the current functionality of prorating the total
       invoice amount amongst all the invoices equally and returning the average commitment. */

    /* Bug 3761335 : removed the exchange_rate_varaince from the select clause if
       p_denom_amt_flag is 'Y' , exchange_rate_varaince should not be considered in case of
       transaction currency amount , it should be considered only in case of
       functional currency amount */

    if (p_module = 'AP') then
      if(l_rcpt_amt is NOT NULL) Then   /* Bug 3394153 :Added If Condition. */
               select count(*),
                      sum(decode(p_denom_amt_flag,
                          'Y', amount,
                          'N', nvl(base_amount,amount)))
               into l_inv_num, l_inv_amt
               from ap_invoice_distributions_all
               where po_distribution_id = p_po_dist
               --and line_type_lookup_code = 'ITEM'
               and line_type_lookup_code <> 'REC_TAX' -- R12 change
               and nvl(reversal_flag,'N') <> 'Y' /* Bug 5673779 */
               and pa_addition_flag not in ('Z','T','E','Y', 'G') /** Added for bug 3167288 **/
               ;
       Else /* Bug 3394153: Added Else Block. */
         -- R12 change
               select sum(decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
                          'Y', amount,
                          'N', nvl(base_amount,amount)))
               into l_inv_amt
               from ap_invoice_distributions_all
               where po_distribution_id = p_po_dist
                 and invoice_id = p_invoice_id
                 -- and distribution_line_number = p_dist_line_num --R12 change
                 and invoice_distribution_id = p_inv_dist_id -- R12 change
                 and line_type_lookup_code <> 'REC_TAX'  --R12 change
                 and nvl(reversal_flag,'N') <> 'Y' /* Bug 5673779 */
                 and pa_addition_flag not in ('Z','T','E','Y', 'G' ) ;

                l_var_amt := nvl(p_var_amt,0);

                l_inv_amt := l_inv_amt + l_var_amt;

                return l_inv_amt;

      End If;   /* Bug 3394153 : End Of Changes */
    End If;
       --dbms_output.put_line('no. of invoices = ' || nvl(l_inv_num,0));
       --dbms_output.put_line('total inv amount = ' || nvl(l_inv_amt,0));

    l_var_amt := nvl(p_var_amt,0);


    if (p_module = 'AP') then
       l_rcpt_amt := greatest(0,greatest((l_inv_amt-nvl(l_rcpt_amt,0)),0)/nvl(l_inv_num,1)) + l_var_amt;
       --dbms_output.put_line('rcpt in AP= '||l_rcpt_amt);
    end if;

    return l_rcpt_amt;

EXCEPTION
   when no_data_found then
--	  Null;  Bug 3864527
        return 0;
END get_inv_cmt;


--bug:4610727 determine outstanding qty on ap distribution.
-- following function is used by grants views.
--
   function get_apdist_qty( p_inv_dist_id    in NUMBER,
                            p_invoice_id     in NUMBER,
			    p_cost           in NUMBER,
			    p_quantity       in NUMBER,
			    p_calling_module in varchar2,
			    p_denom_amt_flag in varchar2,
			    P_CASH_BASIS_ACCTG in varchar2 default 'N'
			    ) return number is
     l_os_amount number ;
     l_inv_amt   number ;
     l_inv_qty   number ;
     l_pay_amt   number ;
     l_disc_amt  number ;
     l_prepay_amt number ;
     l_discount_start_date VARCHAR2(15);
     l_system_discount    DATE ;
   begin

        IF p_calling_module <> 'GMS' then
	   return p_quantity ;
        END IF ;

	l_inv_amt   := p_cost ;

	IF P_CASH_BASIS_ACCTG = 'N' and p_calling_module = 'GMS' then
	   return p_quantity ;
	end if ;

       IF NVL(l_inv_amt,0) <> 0 THEN
               --l_discount_start_date := nvl(fnd_profile.value_specific('PA_DISC_PULL_START_DATE'),'2051/01/01') ; /* Bug 4474213 */
	       --l_system_discount     := fnd_date.canonical_to_date(l_discount_start_date);

               --    4905546
               --    ap_payment_hist_dists has discounts and cash records. we need to include quantity
               --    only for the payment otherwise quantity would double because of discount.
               --    adding the criteria to filter discounts for payment.


               --
               -- Bug : 4962731
               --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
               --
	       --IF l_system_discount > TRUNC(SYSDATE) THEN
	          select sum( decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
			             'Y', paydist.amount,
			             'N', nvl(paydist.paid_base_amount,paydist.amount)))
	            into  l_pay_amt
	            from  ap_payment_hist_dists paydist
	           where paydist.invoice_distribution_id = p_inv_dist_id
		     and NVL(paydist.pa_addition_flag,'N')  <> 'N'
                     and paydist.pay_dist_lookup_code    = 'CASH';

		  -- discount method is PRORATE and not interfaced to Projects. Hence the pa addition flag is never
		  -- switched to Y in this case. We need to consider discounts for the payment line that has interfaced to
		  -- projects.

		  --
		  -- Bug : 4962731
		  --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
		  --
	           select sum( decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
			               'Y', paydist1.amount,
			               'N', nvl(paydist1.paid_base_amount,paydist1.amount)))
	             into  l_disc_amt
	             from  ap_payment_hist_dists paydist1,
		          ap_payment_hist_dists paydist2
	            where paydist1.invoice_distribution_id = p_inv_dist_id
		      and paydist2.invoice_distribution_id = p_inv_dist_id
		      and paydist2.invoice_distribution_id = paydist1.invoice_distribution_id
		      and paydist2.payment_history_id      = paydist1.payment_history_id
		      and paydist2.invoice_payment_id      = paydist1.invoice_payment_id
		      and paydist2.pay_dist_lookup_code    = 'CASH'
		      and paydist1.pay_dist_lookup_code   IN (  'DISCOUNT' )
		       and NVL(paydist2.pa_addition_flag,'N')  <> 'N' ;
		  --
		  -- Bug : 4962731
		  --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
		  --

                    l_pay_amt := NVL(l_pay_amt,0) + NVL(l_disc_amt,0) ;

	       --END IF ;

	       select sum( decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
		  'Y', ppaydist.amount,
		  'N', nvl(ppaydist.base_amount,ppaydist.amount)))
	     into  l_prepay_amt
	     from  ap_prepay_app_dists ppaydist
	    where ppaydist.invoice_distribution_id = p_inv_dist_id
	      and NVL(ppaydist.pa_addition_flag,'N')  <> 'N' ;

	   l_pay_amt := nvl(l_pay_amt,0) + ( nvl(l_prepay_amt,0) * -1 )  ;

       END IF ;

       l_os_amount := NVL(l_inv_amt,0) - NVL(l_pay_amt,0) ;
       l_inv_qty   := (nvl(l_os_amount,0)/nvl(p_cost,1) ) * nvl(p_quantity,0) ;

       return l_inv_qty  ;

end get_apdist_qty;


--bug:4610727 determine outstanding amount on ap distribution.
function get_apdist_amt( p_inv_dist_id    in NUMBER,
                         p_invoice_id     in NUMBER,
                         p_cost           in NUMBER,
		         p_denom_amt_flag in varchar2,
			 p_calling_module in varchar2,
			 P_CASH_BASIS_ACCTG in varchar2 default 'N'
			 ) return number is

     l_os_amount  number ;
     l_inv_amt    number ;
     l_pay_amt    number ;
     l_disc_amt   number ;
     l_prepay_amt number ;

     l_discount_start_date VARCHAR2(15);
     l_system_discount    DATE ;

   begin

     l_inv_amt   := p_cost ;

	IF P_CASH_BASIS_ACCTG = 'N' and p_calling_module = 'GMS' then
	   return l_inv_amt ;
	end if ;

	IF  p_calling_module = 'PA' THEN

               select decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
                          'Y', dist.amount,
                          'N', nvl(dist.base_amount,dist.amount))
               into  l_inv_amt
               from  ap_invoice_distributions_all dist
               where invoice_id = p_invoice_id
               and   dist.invoice_distribution_id = p_inv_dist_id ;

	END IF ;


	IF NVL(l_inv_amt,0) <> 0 THEN
               --l_discount_start_date := nvl(fnd_profile.value_specific('PA_DISC_PULL_START_DATE'),'2051/01/01') ; /* Bug 4474213 */
	       --l_system_discount     := fnd_date.canonical_to_date(l_discount_start_date);

               --    4905546
               --    ap_payment_hist_dists has discounts and cash records. we need to include quantity
               --    only for the payment otherwise quantity would double because of discount.
               --    adding the criteria to filter discounts for payment.
	       --
	       -- Bug : 4962731
	       --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
	       --
	       --IF l_system_discount > TRUNC(SYSDATE) THEN
	          select sum( decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
			             'Y', paydist.amount,
			             'N', nvl(paydist.paid_base_amount,paydist.amount)))
	            into  l_pay_amt
	            from  ap_payment_hist_dists paydist
	           where paydist.invoice_distribution_id = p_inv_dist_id
                     and paydist.pay_dist_lookup_code    = 'CASH'
		     and NVL(paydist.pa_addition_flag,'N')  <> 'N' ;

	       --ELSE

		  -- discount method is PRORATE and not interfaced to Projects. Hence the pa addition flag is never
		  -- switched to Y in this case. We need to consider discounts for the payment line that has interfaced to
		  -- projects.
		  --
		  -- Bug : 4962731
		  --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
		  --

	           select sum( decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
			               'Y', paydist1.amount,
			               'N', nvl(paydist1.paid_base_amount,paydist1.amount)))
	             into  l_disc_amt
	             from  ap_payment_hist_dists paydist1,
		          ap_payment_hist_dists paydist2
	            where paydist1.invoice_distribution_id = p_inv_dist_id
		      and paydist2.invoice_distribution_id = p_inv_dist_id
		      and paydist2.invoice_distribution_id = paydist1.invoice_distribution_id
		      and paydist2.payment_history_id      = paydist1.payment_history_id
		      and paydist2.invoice_payment_id      = paydist1.invoice_payment_id
		      and paydist2.pay_dist_lookup_code    = 'CASH'
		      and paydist1.pay_dist_lookup_code   IN ( 'DISCOUNT' )
		       and NVL(paydist2.pa_addition_flag,'N')  <> 'N' ;

	       --
	       -- Bug : 4962731
	       --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
	       l_pay_amt := NVL(l_pay_amt,0) + NVL(l_disc_amt,0) ;

          --END IF ;

	   select sum( decode(p_denom_amt_flag, /* Bug 4015448. Added Dummy Sum */
		  'Y', ppaydist.amount,
		  'N', nvl(ppaydist.base_amount,ppaydist.amount)))
	     into  l_prepay_amt
	     from  ap_prepay_app_dists ppaydist
	    where ppaydist.invoice_distribution_id = p_inv_dist_id
	      and NVL(ppaydist.pa_addition_flag,'N')  <> 'N' ;

	   l_pay_amt := nvl(l_pay_amt,0) + ( nvl(l_prepay_amt,0) * -1 )  ;

	END IF ;

	l_os_amount := NVL(l_inv_amt,0) - NVL(l_pay_amt,0) ;

	return l_os_amount ;
end get_apdist_amt;


/* Bug:4914006  R12.PJ:XB3:QA:APL:PREPAYMENT COMMITMENT AMOUNT NOT REDUCED AFTER   */
function get_inv_cmt(p_po_dist in number,
                     p_denom_amt_flag in varchar2,
                     p_pa_add_flag in varchar2,
                     p_var_amt in number,
                     p_ccid   in number,
                     p_module in varchar2,
                     p_invoice_id       in number DEFAULT NULL ,        /* Added for Bug 3394153 */
                     p_dist_line_num    in number DEFAULT NULL,         /* Added for Bug 3394153 */
                     p_inv_dist_id      in number DEFAULT NULL,
                     p_accrue_on_rcpt_flag in varchar2,
                     p_po_line_id in number,
                     p_forqty     in varchar2,
                     p_cost       in number,
                     p_project_id in number,
                     p_dist_type  in varchar2,
                     p_pa_quantity in number,  -- Bug 3556021
                     p_inv_source  in varchar2,
		     P_CASH_BASIS_ACCTG in varchar2 default 'N',
		     p_inv_type    in varchar2,
		     p_hist_flag   in varchar2,
		     p_prepay_amt_remaining in number
		     ) return number -- Bug 3556021
Is

   L_RateBasedPO    Varchar2(1);
   L_CWKTCXface     Varchar2(1);

   L_Ret_Amt        Number;
   L_Ret_val        Number;
   l_Var_Amt        Number;
   l_dummy          NUMBER; -- Bug 3529107
   l_exchange_rate  NUMBER ;

   l_po_line_type   Varchar2(30) := 'QUANTITY';

   -- Bug 3529107 :
   -- This cursor is added to further validate the Ap invoice before filtering out
   -- from PSI commitments window.These vaildations are done in addition to what are done
   -- at pa_proj_ap_inv_distributions view level so that the logic is in sync with
   -- update statment in paapimp_pkg.mark_inv_var_paflag procedure which updates
   -- these records to 'G' status during "PRC : Interface supplier cost" process.

   CURSOR C_Valid_Invoice IS
   SELECT 1
     FROM ap_invoices_all
    WHERE invoice_id = p_invoice_id
      AND invoice_type_lookup_code <> 'EXPENSE REPORT'
      AND nvl(source, 'xx' ) NOT IN ('PA_COST_ADJUSTMENTS');

   --
   -- Bug : 5522820
   --       R12.PJ:XB9:QA:APL: PREPAYMENT IN FOREIGN CURRENCY - FUNC COST INCORRECT IN PSI
   --
   CURSOR C_currency_attributes IS
   SELECT exchange_rate
     FROM ap_invoices_all
    WHERE invoice_id = p_invoice_id ;

   l_av number;
   l_base_av number;
   l_in_var_amt number;

Begin

    L_RateBasedPO :=  Pa_Pjc_Cwk_Utils.Is_Rate_Based_Line(p_po_line_id, null);
    L_CWKTCXface :=  Pa_Pjc_Cwk_Utils.Is_Cwk_TC_Xface_Allowed(P_Project_Id);

    -- R12 change for cash basis accounting.
     If p_po_dist is not null and p_forqty = 'Y' then

      select nvl(pll.matching_basis, 'QUANTITY') /* modified for bug bug 3496492 */
        into l_po_line_type
        from po_lines_all po_line,
             po_distributions_all po_dist,
             po_line_locations_all pll
       where Po_dist.distribution_type <> 'PREPAYMENT'
         and pll.po_line_id = po_line.po_line_id
         and po_line.po_line_id = po_dist.po_line_id
         and po_dist.po_distribution_id = p_po_dist;

    End if;
    --{
    --4610727 - PJ.R12:DI1:APLINES: PSI OUTSTANDING AMOUNT FOR AP IN CASH BASED ACCOUNTING
    IF NVL(P_CASH_BASIS_ACCTG, 'N') = 'Y' then

       --{{
       IF L_RateBasedPO = 'Y' and L_CWKTCXface = 'Y' Then
          --{{{

	  -- Rate based PO project impl option allows to interface time card into projects.
	  -- item line is not reported as commitment because timecard will be processed in projects
	  -- For tax and variance lines we need to return outstanding amount i.e.
	  -- Invoice distribution amount - payament interfaced amount.
          IF p_dist_type not in ( 'ACCRUAL', 'ITEM')  THEN


             IF p_dist_type = 'PREPAY' then
	        l_ret_amt := p_cost ;
	     ELSE
	        -- R12 will have a separate line for the tax and variance and we need to determine
		    -- the outstanding amount based on Invoice distribution amount and payament
		    -- amount that has interface to projects..

		    -- BUG 4914006
		    -- Prepayment discount is not applicable and also payment never gets
		    -- interfaced to projects. So we should be looking at the amount remaining
		    -- on prepayments.
            IF p_inv_type = 'PREPAYMENT'   and
	       NVL(p_hist_flag,'N') <> 'Y' and
               p_forqty  <> 'Y' then

               l_ret_amt :=  p_prepay_amt_remaining ;

	       --
	       -- Bug : 5522820
	       --       R12.PJ:XB9:QA:APL: PREPAYMENT IN FOREIGN CURRENCY - FUNC COST INCORRECT IN PSI
	       --
	       IF p_denom_amt_flag = 'N' THEN
	           open C_currency_attributes ;
		   fetch C_currency_attributes into l_exchange_rate ;
		   close C_currency_attributes ;
		   l_exchange_rate := NVL(l_exchange_rate,1) ;
		   l_ret_amt := l_exchange_rate * p_prepay_amt_remaining ;
		   l_ret_amt := pa_currency.round_currency_amt( l_ret_amt ) ;

	       END IF ;

	       -- Prepayment has not been paid yet.
	       -- Bug: 5393523 Unpaid prepayments do not show in PSI.
	       IF p_prepay_amt_remaining is NULL then
	          l_ret_amt := get_apdist_amt( p_inv_dist_id,
		                               p_invoice_id,
					       NULL,
					       p_denom_amt_flag,
					       'PA',
					       P_CASH_BASIS_ACCTG );
	       END IF ;
            ELSE
	   	      --
	          l_ret_amt := get_apdist_amt( p_inv_dist_id, p_invoice_id, NULL, p_denom_amt_flag, 'PA',P_CASH_BASIS_ACCTG );
            END IF ;

	     END IF ;

	  ELSE
	  -- Rate based po with timecard interfaced in projects corresponding to the
	  -- item line and no outstanding amount as commitment.

	     l_ret_amt := nvl(p_var_amt,0) ;

	  END IF ;
	  --}}}
       ELSE
       --{{ continue
       --
       -- Cash based accounting for standard ap invoices and non rate based pos or when interface
       -- invoice option is set in project impl option.

       -- Apply prepay amount will be reported as it is because there is no payament for
       -- prepayment application and this is reported as invoice cost.
       --
             IF p_dist_type = 'PREPAY' then
	        l_ret_amt := p_cost ;
	     ELSE
	        -- We need to determine the outstanding invoice amount based on Invoice distribution
		-- amount and payament amount that has interface to projects..
		--
                IF p_inv_type = 'PREPAYMENT' and NVL(p_hist_flag,'N') <> 'Y' and
                   p_forqty  <> 'Y' then
                   l_ret_amt :=  p_prepay_amt_remaining ;

	           --
	           -- Bug : 5522820
	           --       R12.PJ:XB9:QA:APL: PREPAYMENT IN FOREIGN CURRENCY - FUNC COST INCORRECT IN PSI
	           --
	           IF p_denom_amt_flag = 'N' THEN
	              open C_currency_attributes ;
		      fetch C_currency_attributes into l_exchange_rate ;
		      close C_currency_attributes ;
		      l_exchange_rate := NVL(l_exchange_rate,1) ;
		      l_ret_amt := l_exchange_rate * p_prepay_amt_remaining ;
		      l_ret_amt := pa_currency.round_currency_amt( l_ret_amt ) ;

	         END IF ;


	           -- Prepayment has not been paid yet.
	           -- Bug: 5393523 Unpaid prepayments do not show in PSI.
		   IF p_prepay_amt_remaining is NULL THEN
	              l_ret_amt := get_apdist_amt( p_inv_dist_id,
		                                   p_invoice_id,
						   NULL,
						   p_denom_amt_flag,
						   'PA',
						   P_CASH_BASIS_ACCTG );
		   END IF ;
		ELSE
	           l_ret_amt := get_apdist_amt( p_inv_dist_id, p_invoice_id, NULL, p_denom_amt_flag, 'PA', P_CASH_BASIS_ACCTG );
                END IF ;

	     END IF ;
       END IF ;
       --}} end of cash based processing
       IF p_forqty = 'Y' then
          IF l_po_line_type <> 'AMOUNT' then
	     l_ret_amt :=  round((l_ret_amt/ p_cost) * nvl(p_pa_quantity,0), 2) ;
          end if ;
       end if ;
       return l_ret_amt ;
    END IF ;
    --4610727 - PJ.R12:DI1:APLINES: PSI OUTSTANDING AMOUNT FOR AP IN CASH BASED ACCOUNTING
    -- end of fix.


    l_in_var_amt := p_var_amt;

    If L_RateBasedPO = 'Y' and L_CWKTCXface = 'Y' Then ---{

       -- For Rate based or Amount based Po's quantity is same as amount

       -- Bug 3529107 : Added the below IF condition such that AP distributions (Non NRT Lines
       -- and NON variance lines) matched to a Rate based PO will not be shown as commitments
       -- in PSI as these lines will never be interfaced to PA .
       IF p_dist_type <> 'TAX' then

          OPEN  C_Valid_Invoice;
          FETCH C_Valid_Invoice INTO l_dummy;
          IF C_Valid_Invoice%FOUND THEN
             CLOSE C_Valid_Invoice;

             --For the standard invoice distributions (i.e. non tax distributons), appropriate
             --variance amounts must be returned depending on whether the variances are
             --interfaced to PA or not.
             IF p_dist_type in ( 'ACCRUAL',  'ITEM')  THEN
                l_Ret_Amt := nvl(p_var_amt,0) ;
             ELSE
	        l_Ret_Amt := p_cost ;
	     END IF ;
             RETURN l_Ret_Amt;
          END IF;
          CLOSE C_Valid_Invoice;
      END IF ;

       --For Tax distributions
       IF p_accrue_on_rcpt_flag = 'Y' Then  -- {

             --Call get_inv_cmt
                 L_Ret_Amt := PA_CMT_UTILS.get_inv_cmt(p_po_dist,
                                                       p_denom_amt_flag,
                                                       p_pa_add_flag,
                                                       l_in_var_amt,
                                                       p_ccid,
                                                       'AP',
                                                       p_invoice_id,
                                                       -- bug : 4671855
                                                       p_dist_line_num ,
                                                       p_inv_dist_id,
							   		                   P_CASH_BASIS_ACCTG);
       Else

          l_var_amt := nvl(l_in_var_amt,0);

          if (p_module = 'AP') then
             IF p_inv_type = 'PREPAYMENT' AND NVL(p_hist_flag,'N') <> 'Y' and
                 p_forqty  <> 'Y' then
                 l_ret_amt :=  p_prepay_amt_remaining ;
	           --
	           -- Bug : 5522820
	           --       R12.PJ:XB9:QA:APL: PREPAYMENT IN FOREIGN CURRENCY - FUNC COST INCORRECT IN PSI
	           --
	         IF p_denom_amt_flag = 'N' THEN
	           open C_currency_attributes ;
		   fetch C_currency_attributes into l_exchange_rate ;
		   close C_currency_attributes ;
		   l_exchange_rate := NVL(l_exchange_rate,1) ;
		   l_ret_amt := l_exchange_rate * p_prepay_amt_remaining ;
		   l_ret_amt := pa_currency.round_currency_amt( l_ret_amt ) ;

	         END IF ;


	         -- Prepayment has not been paid yet.
	         -- Bug: 5393523 Unpaid prepayments do not show in PSI.
		 IF p_prepay_amt_remaining is NULL then
                    l_Ret_Amt := (P_Cost - l_var_amt);
		 END IF ;
             ELSE
                 l_Ret_Amt := (P_Cost - l_var_amt);
             END IF ;

          end if;

       End If;                    -- }

    Else

       If p_accrue_on_rcpt_flag = 'Y' Then   -- {

          If p_forqty = 'Y' and l_po_line_type <> 'AMOUNT' Then

             --Call get_rcpt_qty

                 L_Ret_Amt := PA_CMT_UTILS.get_rcpt_qty(p_po_dist,0,0,0,'AP',p_po_line_id,p_project_id,null,p_ccid,
                                                    p_pa_quantity,p_inv_source,p_dist_type,l_po_line_type,null, -- Bug 3556021
										  P_CASH_BASIS_ACCTG, p_accrue_on_rcpt_flag);

          Else

             --Call get_inv_cmt
             L_Ret_Amt := PA_CMT_UTILS.get_inv_cmt(p_po_dist,
                                                p_denom_amt_flag,
                                                p_pa_add_flag,
                                                l_in_var_amt,
                                                p_ccid,
                                                'AP',
                                                p_invoice_id,
                                                -- bug : 4671855
                                                p_dist_line_num ,
                                                p_inv_dist_id,
									   P_CASH_BASIS_ACCTG);
          End If;

      Else

           L_Ret_val := p_cost ;
           IF p_inv_type = 'PREPAYMENT' AND NVL(p_hist_flag,'N') <> 'Y' and
                 p_forqty  <> 'Y' then
                 l_ret_val :=  p_prepay_amt_remaining ;

	           --
	           -- Bug : 5522820
	           --       R12.PJ:XB9:QA:APL: PREPAYMENT IN FOREIGN CURRENCY - FUNC COST INCORRECT IN PSI
	           --
	         IF p_denom_amt_flag = 'N' THEN
	           open C_currency_attributes ;
		   fetch C_currency_attributes into l_exchange_rate ;
		   close C_currency_attributes ;
		   l_exchange_rate := NVL(l_exchange_rate,1) ;
		   l_ret_val := l_exchange_rate * p_prepay_amt_remaining ;
		   l_ret_val := pa_currency.round_currency_amt( l_ret_val ) ;

	         END IF ;

	         -- Prepayment has not been paid yet.
	         -- Bug: 5393523 Unpaid prepayments do not show in PSI.
		 IF p_prepay_amt_remaining is NULL then
		    L_Ret_val := p_cost ;
		 END IF ;
            END IF ;

          Select decode(p_forqty,'Y', decode(l_po_line_type,'AMOUNT',l_ret_val,p_pa_quantity),l_ret_val)
          into   l_ret_val
          from dual;

          --Select decode(p_forqty,'Y', decode(l_po_line_type,'AMOUNT',p_cost,p_pa_quantity),p_cost)
          --into   l_ret_val
          --from dual;

          l_Ret_Amt := l_ret_val;

      End If;                        -- }

   End If;  ---}

   Return l_Ret_Amt;

Exception

   When No_Data_Found Then
--        Null;  Bug 3864527
        return 0;

   When Others Then
--	  Null; Bug 3864527
	return 0;

End get_inv_cmt;

--R12 changes for AP LINES uptake
function get_inv_var(p_inv_dist in number,
                     p_denom_amt_flag in varchar2,
                     p_amt_var in number,
                     p_qty_var in number
                    ) return number
IS
   l_Var_Amt        Number;
BEGIN
     -- 4610727 - PJ.R12:DI1:APLINES: PSI OUTSTANDING AMOUNT FOR AP IN CASH BASED ACCOUNTING
     -- R12 we will have variance on a separate distribution and hence we do not need to determine the
     -- variance amount.
     -- only in case of amount based po we may have amount variance on the same distribution
     -- as item and hence we can return the amount variance value back here.
     return  nvl(p_amt_var,0) ;

END get_inv_var;

/*Introduced for bug 5946201*/
FUNCTION Is_eIB_item     ( p_po_dist_id      IN   NUMBER
                          ) RETURN VARCHAR2 IS
 l_flag  varchar2(1) := 'N';
BEGIN
 select distinct msi.comms_nl_trackable_flag,nvl(pod.accrue_on_receipt_flag,'N')
 into l_flag,g_accrue_on_receipt_flag
 from
 mtl_system_items msi ,
 po_distributions_all pod,
 po_lines_all pol
 where
 msi.inventory_item_id=pol.item_id
 and pol.po_line_id=pod.po_line_id
 and pod.po_distribution_id = p_po_dist_id;


 Return l_flag;

EXCEPTION
  WHEN OTHERS THEN

   RETURN 'N' ;

END Is_eIB_item;


END PA_CMT_UTILS;

/
