--------------------------------------------------------
--  DDL for Package Body PO_POXQUAPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXQUAPR_XMLP_PKG" AS
/* $Header: POXQUAPRB.pls 120.1 2007/12/25 11:36:49 krreddy noship $ */

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (get_p_struct_num <> TRUE)
    then /*SRW.MESSAGE('1','P Struct Num init failed.');*/null;

  END IF;

  If (P_detail_summary = 'Y' ) then P_report_type := 1 ;
   else P_report_type := 0 ;
  end if;


 null;


 null;


 null;
FORMAT_MASK := PO_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
  RETURN TRUE;

END;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
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

else /*srw.attr.formatmask  :=  '-NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

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

function per_acceptedformula(Received in number, Accepted in number) return number is
begin

/*SRW.reference(Accepted) ;*/null;

/*SRW.reference(Received) ;*/null;

if (Received = 0) then return(0) ;
else return ROUND(((Accepted / Received) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function per_rejectedformula(Received in number, Rejected in number) return number is
begin

/*SRW.reference(Received) ;*/null;

/*SRW.reference(Rejected) ;*/null;

if (Received = 0) then return (0) ;
else return ROUND(((Rejected / Received) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function per_returnedformula(Received in number, Returned in number) return number is
begin

/*SRW.reference(Received) ;*/null;

/*SRW.reference(Returned) ;*/null;

if (Received = 0) then return(0) ;
else return ROUND(((Returned / Received ) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function c_item_per_acceptedformula(C_item_sum_rec in number, C_item_sum_acc in number) return number is
begin

/*SRW.reference(C_item_sum_rec) ;*/null;

/*SRW.reference(C_item_sum_acc) ;*/null;

if (C_item_sum_rec = 0) then return(0) ;
else return ROUND(((C_item_sum_acc / C_item_sum_rec ) * 100 ), P_qty_precision );
end if;
RETURN NULL; end;

function c_item_per_rejectedformula(C_item_sum_rec in number, C_item_sum_rej in number) return number is
begin

/*SRW.reference(C_item_sum_rec) ;*/null;

/*SRW.reference(C_item_sum_rej) ;*/null;

if (C_item_sum_rec = 0) then return(0) ;
else return ROUND(((C_item_sum_rej / C_item_sum_rec ) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function c_item_per_returnedformula(C_item_sum_rec in number, C_item_sum_ret in number) return number is
begin

/*SRW.reference(C_item_sum_rec) ;*/null;

/*SRW.reference(C_item_sum_ret) ;*/null;

if (C_item_sum_rec = 0) then return(0) ;
else return ROUND(((C_item_sum_ret / C_item_sum_rec) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function uninspectedformula(Received in number, Accepted in number, Rejected in number) return number is
begin

/*srw.reference(Received) ;*/null;

/*srw.reference(Accepted) ;*/null;

/*srw.reference(Rejected) ;*/null;

return (Received - Accepted - Rejected ) ;
end;

function per_uninspectedformula(Received in number, Uninspected in number) return number is
begin

/*SRW.reference(Received) ;*/null;

/*SRW.reference(Uninspected) ;*/null;

if (Received = 0) then return (0) ;
else return ROUND(((Uninspected / Received) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function per_rtv_wout_inspectformula(Received in number, Rtv_wout_inspect in number) return number is
begin

/*SRW.reference(Received) ;*/null;

/*SRW.reference(Rtv_wout_inspect) ;*/null;

if (Received = 0) then return(0) ;
else return ROUND(((Rtv_wout_inspect / Received ) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function c_item_per_uninsformula(C_item_sum_rec in number, C_item_sum_unins in number) return number is
begin

/*SRW.reference(C_item_sum_rec) ;*/null;

/*SRW.reference(C_item_sum_unins) ;*/null;

if (C_item_sum_rec = 0) then return(0) ;
else return ROUND(((C_item_sum_unins / C_item_sum_rec ) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function c_item_per_rtv_wout_insformula(C_item_sum_rec in number, C_item_sum_rtv_wout_ins in number) return number is
begin

/*SRW.reference(C_item_sum_rec) ;*/null;

/*SRW.reference(C_item_sum_rtv_wout_ins) ;*/null;

if (C_item_sum_rec = 0) then return(0) ;
else return ROUND(((C_item_sum_rtv_wout_ins / C_item_sum_rec) * 100 ), P_qty_precision) ;
end if;
RETURN NULL; end;

function quantity_acceptedformula(pll_quantity_accepted in number, conversion_rate in varchar2) return number is
begin

/*srw.reference(conversion_rate) ;*/null;

/*srw.reference(pll_quantity_accepted) ;*/null;

return(pll_quantity_accepted * conversion_rate ) ;
end;

function quantity_rejectedformula(conversion_rate in varchar2, pll_quantity_rejected in number) return number is
begin

/*srw.reference(conversion_rate) ;*/null;

/*srw.reference(pll_quantity_rejected) ;*/null;

return(conversion_rate * pll_quantity_rejected ) ;
end;

function quantity_orderedformula(conversion_rate in varchar2, pll_quantity_ordered in number) return number is
begin

/*srw.reference(conversion_rate) ;*/null;

/*srw.reference(pll_quantity_ordered) ;*/null;

return(conversion_rate * pll_quantity_ordered ) ;
end;

function c_tot_returnedformula(parent_line_location_id in number, Item_id in number) return number is
begin

begin
declare

ret_qty number;
cor_qty number;

quantity_returned number;

begin

select sum(rct.primary_quantity) into ret_qty
from rcv_transactions     rct
where rct.transaction_type = 'RETURN TO VENDOR'
and   rct.po_line_location_id = parent_line_location_id
UNION
select sum(rct.primary_quantity)
from rcv_transactions     rct
where rct.transaction_type = 'RETURN TO VENDOR'
and   rct.po_line_location_id = parent_line_location_id
and Item_id is NULL
group by rct.po_line_location_id;

select sum(rct.primary_quantity) into cor_qty
from rcv_transactions     rct, rcv_transactions rct1
where rct.transaction_type = 'CORRECT'
and   rct.po_line_location_id = parent_line_location_id
and   rct.parent_transaction_id = rct1.transaction_id
and   rct1.transaction_type = 'RETURN TO VENDOR'
UNION
select sum(rct.primary_quantity)
from rcv_transactions     rct, rcv_transactions rct1
where rct.transaction_type = 'CORRECT'
and   rct.po_line_location_id = parent_line_location_id
and Item_id is NULL
and   rct.parent_transaction_id = rct1.transaction_id
and   rct1.transaction_type = 'RETURN TO VENDOR'
group by rct.po_line_location_id;

quantity_returned := nvl(ret_qty,0) + nvl(cor_qty,0);
return(quantity_returned);

end;
end;
RETURN NULL; end;

function c_tot_inspectedformula(parent_line_location_id in number, Item_id in number) return number is
begin

begin
declare

ins_qty number;
cor_qty number;

quantity_inspected number;

begin

select sum(rct.primary_quantity) into ins_qty
from rcv_transactions     rct
where rct.transaction_type = 'RETURN TO VENDOR'
and nvl(rct.inspection_status_code,'NOT INSPECTED') = 'NOT INSPECTED'
and   rct.po_line_location_id = parent_line_location_id
UNION
select sum(rct.primary_quantity)
from rcv_transactions     rct
where rct.transaction_type = 'RETURN TO VENDOR'
and nvl(rct.inspection_status_code,'NOT INSPECTED') = 'NOT INSPECTED'
and   rct.po_line_location_id = parent_line_location_id
and Item_id is NULL
group by rct.po_line_location_id;

select sum(rct.primary_quantity) into cor_qty
from rcv_transactions     rct, rcv_transactions rct1
where rct.transaction_type = 'CORRECT'
and   rct.po_line_location_id = parent_line_location_id
and   rct.parent_transaction_id = rct1.transaction_id
and   rct1.transaction_type = 'RETURN TO VENDOR'
and nvl(rct1.inspection_status_code,'NOT INSPECTED') = 'NOT INSPECTED'
UNION
select sum(rct.primary_quantity)
from rcv_transactions     rct, rcv_transactions rct1
where rct.transaction_type = 'CORRECT'
and   rct.po_line_location_id = parent_line_location_id
and Item_id is NULL
and   rct.parent_transaction_id = rct1.transaction_id
and   rct1.transaction_type = 'RETURN TO VENDOR'
and nvl(rct1.inspection_status_code,'NOT INSPECTED') = 'NOT INSPECTED'
group by rct.po_line_location_id;

quantity_inspected := nvl(ins_qty,0) + nvl(cor_qty,0);
return(quantity_inspected);

end;
end;
RETURN NULL; end;

function c_tot_receivedformula(parent_line_location_id in number, Item_id in number) return number is
begin

begin
declare

rec_qty number;
cor_qty number;

quantity_received number;

begin

select sum(rct.primary_quantity) into rec_qty
from rcv_transactions     rct
where rct.transaction_type = 'RECEIVE'
and   rct.po_line_location_id = parent_line_location_id
UNION
select sum(rct.primary_quantity)
from rcv_transactions     rct
where rct.transaction_type = 'RECEIVE'
and   rct.po_line_location_id = parent_line_location_id
and Item_id is NULL
group by rct.po_line_location_id;

select sum(rct.primary_quantity) into cor_qty
from rcv_transactions     rct, rcv_transactions rct1
where rct.transaction_type = 'CORRECT'
and   rct.po_line_location_id = parent_line_location_id
and   rct.parent_transaction_id = rct1.transaction_id
and   rct1.transaction_type = 'RECEIVE'
UNION
select sum(rct.primary_quantity)
from rcv_transactions     rct, rcv_transactions rct1
where rct.transaction_type = 'CORRECT'
and   rct.po_line_location_id = parent_line_location_id
and Item_id is NULL
and   rct.parent_transaction_id = rct1.transaction_id
and   rct1.transaction_type = 'RECEIVE'
group by rct.po_line_location_id;

quantity_received := nvl(rec_qty,0) + nvl(cor_qty,0);
return(quantity_received);

end;
end;
RETURN NULL; end;

--Functions to refer Oracle report placeholders--

END PO_POXQUAPR_XMLP_PKG ;


/
