--------------------------------------------------------
--  DDL for Package Body PO_POXPOEDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOEDR_XMLP_PKG" AS
/* $Header: POXPOEDRB.pls 120.1.12010000.2 2013/04/02 04:21:34 ssindhe ship $ */

function BeforeReport return boolean is
begin

declare
l_po_type     po_lookup_codes.displayed_field%type ;
begin
execute immediate 'Alter session set sql_trace TRUE';
QTY_PRECISION:= po_common_xmlp_pkg.get_precision(P_qty_precision);
if P_type is not null then

    select displayed_field
    into l_po_type
    from po_lookup_codes
    where lookup_code = P_type
    and lookup_type = 'DOCUMENT TYPE';

    P_type_displayed := l_po_type ;

else

    P_type_displayed := '' ;

end if;



  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','Init failed');*/null;

  end if;
  if (get_chart_of_accounts_id <> TRUE )
  then /*SRW.MESSAGE('2','Init failed');*/null;

  end if;

 null;
  IF (P_ACCOUNT_FROM IS NOT NULL) THEN
     IF (P_ACCOUNT_TO IS NOT NULL) THEN
       /*SRW.MESSAGE(1,'with_acc_params');*/null;


 null;
     ELSE
       /*SRW.MESSAGE(1,'wout_acc_params');*/null;


 null;
     END IF;
  ELSE
    IF (P_ACCOUNT_TO IS NOT NULL) THEN
       /*SRW.MESSAGE(1,'wout_acc_to');*/null;


 null;
    END IF;
  END IF;


 null;

 RETURN TRUE;
END;
  return (TRUE);
end;

procedure get_precision is
begin
/*srw.attr.mask        :=  SRW.FORMATMASK_ATTR;*/null;

if P_qty_precision = 0 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0';*/null;

else
if P_qty_precision = 1 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0.0';*/null;

else
if P_qty_precision = 3 then /*srw.attr.formatmask  :=  '-NN,NNN,NNN,NN0.000';*/null;

else
if P_qty_precision = 4 then /*srw.attr.formatmask  :=   '-N,NNN,NNN,NN0.0000';*/null;

else
if P_qty_precision = 5 then /*srw.attr.formatmask  :=     '-NNN,NNN,NN0.00000';*/null;

else
if P_qty_precision = 6 then /*srw.attr.formatmask  :=      '-NN,NNN,NN0.000000';*/null;

else /*srw.attr.formatmask  :=  '-NNN,NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

end;

function c_amount_chg_accformula(C_AMOUNT_REQ_SUBTOTAL in number, C_AMOUNT_PO_SUBTOTAL in number, C_AMOUNT_BPO_SUBTOTAL in number) return number is
begin

 return (nvl(C_AMOUNT_REQ_SUBTOTAL,0)+nvl(C_AMOUNT_PO_SUBTOTAL,0)+nvl(C_AMOUNT_BPO_SUBTOTAL,0));
end;

function AfterReport return boolean is
begin

/*srw.do_sql('Alter session set sql_trace FALSE');*/null;


/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function cost_center(c_cost_center_s in varchar2) return character is
begin
      if c_cost_center_s is null then
      return('gcc.segment4');
      end if;
      return('gcc.'||c_cost_center_s);
end;

function get_p_struct_num return boolean is

l_p_struct_num number;

begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;

        P_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function get_chart_of_accounts_id return boolean is

l_chart_of_accounts_id number;

begin
        select gsob.chart_of_accounts_id
        into l_chart_of_accounts_id
        from gl_sets_of_books gsob,
        financials_system_parameters fsp
        where  fsp.set_of_books_id = gsob.set_of_books_id ;

        P_CHART_OF_ACCOUNTS := l_chart_of_accounts_id ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function c_amount_func_poformula(c_amount_base_po in number, c_currency_base1 in varchar2, c_currency_po in varchar2, rate in number, c_precision in number) return number is
   l_precision   NUMBER;
   l_min_unit    NUMBER;
begin

/*srw.reference(c_amount_base_po);*/null;

/*srw.reference(c_currency_base1);*/null;

/*srw.reference(c_currency_po);*/null;


IF  (c_amount_base_po  <> 0 )  THEN
       if (c_currency_base1 <>  c_currency_po) THEN

           if (cp_old_po_cur <> c_currency_po)  THEN

                 PO_CORE_S2.GET_CURRENCY_INFO(x_currency_code => C_CURRENCY_PO,
                                              x_precision => l_precision,
                                              x_min_unit => l_min_unit);

                 cp_precision_po := l_precision;
                 cp_old_po_cur := c_currency_po;
           end if;
	   return(round(c_amount_base_po/rate,nvl(cp_precision_po,c_precision)));
      else
           return(c_amount_base_po);
      end if;
else
     return(0);

end if;


end;

function c_amount_base_poformula(PO_TYPE in varchar2, po_enc_amount_func in number, accrual_flag in varchar2, parent_join_id in number,c_precision in number) return number is
        l_amount_moved_to_Actual  NUMBER := 0;
        l_active_enc_amount  NUMBER := 0;
        l_po_enc_amount  NUMBER := 0;
        l_return_status      VARCHAR2(1);          l_msg_count          NUMBER;            l_msg_data           VARCHAR2(2000);
begin

/*SRW.reference(parent_join_id);*/null;

/*SRW.reference(P_encumbrance_date_from);*/null;

/*SRW.reference(P_encumbrance_date_to);*/null;

/*SRW.reference(po_enc_amount_func);*/null;


IF (PO_TYPE <> 'PLANNED') THEN
     l_po_enc_amount := nvl(po_enc_amount_func,0);

   IF nvl(accrual_flag, 'N') = 'Y' then

      l_amount_moved_to_actual := RCV_AccrualUtilities_GRP.Get_encumReversalAmt (
				              p_po_distribution_id =>  parent_join_id,
				              p_start_txn_date => P_encumbrance_date_from,
				              p_end_txn_date  =>  P_encumbrance_date_to);


   ELSE
           				PSA_AP_BC_GRP.get_po_reversed_encumb_amount(
               					 p_api_version =>1.0,
						 p_init_msg_list=>'F',
						 x_return_status => l_return_status,
               					 x_msg_count=>l_msg_count,
                				 x_msg_data=>l_msg_data,
               					 p_po_distribution_id => parent_join_id,
               					 p_start_gl_date => P_encumbrance_date_from,
              				         p_end_gl_date => P_encumbrance_date_to,
				                 x_unencumbered_amount => l_amount_moved_to_actual);

   END IF;
ELSE


  l_po_enc_amount := nvl(po_enc_amount_func,0);
  l_amount_moved_to_actual := 0;

END IF;



l_active_enc_amount := l_po_enc_amount -
                       nvl(l_amount_moved_to_actual, 0);

/*Active Encumbrance Amount Can Not be Negative.  We should return Active Encumbrance as Zero, when it is less than Zero.
Commenting the Following If condition to Achieve this.

  -- If the PO encumbered amount is zero, then we should never have a
   -- negative active encumbrance amount.  This needs to be handled as
   -- a separate condition to ensure that for non-federal case with
   -- automatic_encumbrance_flag = 'N', the active encumbrance amount
   -- will not go negative (b/c PO encumbrance will be zero, but there can
   -- be actuals).*/
--IF (po_enc_amount_func = 0) THEN

   l_active_enc_amount := GREATEST(0, l_active_enc_amount);

--END IF;

return(round(l_active_enc_amount,c_precision));

end;

function adjusted_q_orderedformula(po_type in varchar2, p_po_header_id in number, p_po_line_id in number, Parent_join_id in number, quantity_ordered in number) return number is

quantity_released  NUMBER;

BEGIN

   quantity_released := 0;

   IF po_type = 'PLANNED' THEN

	SELECT sum(pod.quantity_ordered - pod.quantity_cancelled)
	into quantity_released
        FROM po_distributions  pod,
             po_line_locations  poll
        WHERE pod.po_release_id IS NOT NULL
        AND   pod.po_header_id = p_po_header_id
        AND   pod.po_line_id = p_po_line_id
        AND   pod.line_location_id = poll.line_location_id
        AND   poll.shipment_type = 'SCHEDULED'
        AND   pod.source_distribution_id = Parent_join_id         AND   ( nvl(pod.encumbered_flag , 'N' ) = 'Y'
                 OR ( nvl(pod.encumbered_flag, 'N') = 'N'
                AND nvl(poll.cancel_flag, 'N') = 'Y')
                 OR (NVL(POLL.closed_code,'OPEN')= 'FINALLY CLOSED'))
        AND   pod.gl_encumbered_date
            BETWEEN nvl(P_encumbrance_date_from, pod.gl_encumbered_date-1)
            AND     nvl(P_encumbrance_date_to, pod.gl_encumbered_date+1);


   END IF;

   RETURN (  quantity_ordered - nvl(quantity_released, 0));

END;

function c_func_amount_bpoformula(c_base_amount_bpo in number, c_currency_base1 in varchar2, c_currency_po1 in varchar2, rate1 in number, c_precision in number) return number is
       l_precision  NUMBER;
       l_min_unit   NUMBER;
begin


/*srw.reference(c_base_amount_bpo);*/null;

/*srw.reference(c_currency_base1);*/null;

/*srw.reference(c_currency_po1);*/null;

IF  (c_base_amount_bpo  <> 0 )  THEN
       if (c_currency_base1 <>  c_currency_po1) THEN

           if (cp_old_bpo_cur <> c_currency_po1)  THEN

                 PO_CORE_S2.GET_CURRENCY_INFO(x_currency_code => C_CURRENCY_PO1,
                                              x_precision => l_precision,
                                              x_min_unit => l_min_unit);

                 cp_precision_bpo := l_precision;
                 cp_old_bpo_cur := c_currency_po1;
           end if;
	   return(greatest(0,round(c_base_amount_bpo/rate1,nvl(cp_precision_bpo,c_precision))));
      else
           return(greatest(0,c_base_amount_bpo));
      end if;
else
     return(0);

end if;


end;

--Functions to refer Oracle report placeholders--

 Function CP_PRECISION_PO_p return number is
	Begin
	 return CP_PRECISION_PO;
	 END;
 Function CP_OLD_PO_CUR_p return varchar2 is
	Begin
	 return CP_OLD_PO_CUR;
	 END;
 Function CP_PRECISION_BPO_p return number is
	Begin
	 return CP_PRECISION_BPO;
	 END;
 Function CP_OLD_BPO_CUR_p return varchar2 is
	Begin
	 return CP_OLD_BPO_CUR;
	 END;
END PO_POXPOEDR_XMLP_PKG ;


/
