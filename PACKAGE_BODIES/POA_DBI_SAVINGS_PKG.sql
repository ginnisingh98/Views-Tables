--------------------------------------------------------
--  DDL for Package Body POA_DBI_SAVINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_SAVINGS_PKG" AS
/* $Header: poadbipodsvgb.pls 115.11 2004/02/12 19:17:52 mangupta noship $ */

 g_po_distribution_id NUMBER := -99999;
 g_lowest_price NUMBER := -99999;
 g_blanket_id NUMBER := -99999;

function get_lowest_possible_price (p_creation_date DATE,
                                    p_org_id IN NUMBER,
                                    p_need_by_date IN DATE,
				    p_quantity IN NUMBER,
				    p_unit_meas_lookup_code IN VARCHAR2,
				    p_currency_code IN VARCHAR2,
				    p_item_id IN NUMBER,
				    p_item_revision in varchar2,
				    p_category_id in number,
				    p_ship_to_location_id IN NUMBER,
                                    p_func_cur_code IN VARCHAR2,
                                    p_rate_date IN DATE,
                                    p_ship_to_ou_id IN NUMBER,
                                    p_ship_to_organization_id IN NUMBER,
                                    p_po_distribution_id IN NUMBER,
                                    p_type IN VARCHAR2)
  RETURN NUMBER
IS

  TYPE T_FLEXREF IS REF CURSOR;

  rlines_cur  T_FLEXREF;
  rline_q NUMBER := 0;
  rline_qa NUMBER := 0;
  rline_a NUMBER := 0;

  cursor pblines_cur(p_item_id number
                     ,p_unit_meas_lookup_code varchar2
                     ,p_creation_date date
                     ,p_currency_code varchar2)
       is
     select bl.po_header_id,b.vendor_id,bl.po_line_id,bl.price_break_lookup_code
        ,bl.unit_price,bl.min_release_amount bl_min,bl.expiration_date
        ,b.min_release_amount b_min,b.amount_limit , b.global_agreement_flag
        ,0 line_qty,0 line_all_qty, gl.currency_code bl_func_cur_code, b.rate bl_rate
   from po_lines_all bl
       ,po_headers_all b
       ,financials_system_params_all fsp
       ,gl_sets_of_books gl
  where bl.item_id = p_item_id
    and bl.price_break_lookup_code is not null
    and bl.unit_meas_lookup_code = p_unit_meas_lookup_code
    and b.org_id = fsp.org_id
    and fsp.set_of_books_id = gl.set_of_books_id
    and ((b.org_id = p_ship_to_ou_id and nvl(b.global_agreement_flag, 'N') = 'N')
          or (b.global_agreement_flag = 'Y' and exists
                (select 'enabled'
                  from po_ga_org_assignments pgoa
                  where pgoa.po_header_id = b.po_header_id
                  and  pgoa.enabled_flag = 'Y'
                  and  ((pgoa.purchasing_org_id in
                           (select tfh.start_org_id
                            from mtl_procuring_txn_flow_hdrs_v tfh,
                                 financials_system_params_all fsp1,
                                 financials_system_params_all fsp2
                            where p_creation_date between nvl(tfh.start_date, p_creation_date) and nvl(tfh.end_date, p_creation_date)
                                  and fsp1.org_id = tfh.start_org_id
                                  and fsp1.purch_encumbrance_flag = 'N'
                                  and fsp2.org_id = tfh.end_org_id
                                  and fsp2.purch_encumbrance_flag = 'N'
                                  and tfh.end_org_id = p_ship_to_ou_id
                                  and ((tfh.qualifier_code is null) or (tfh.qualifier_code = 1 and tfh.qualifier_value_id = p_category_id))
                                  and ((tfh.organization_id is null) or (tfh.organization_id = p_ship_to_organization_id))
                            )
                        )
                        or (nvl(pgoa.purchasing_org_id, p_ship_to_ou_id) = p_ship_to_ou_id))
        )))
    and nvl(bl.cancel_flag, 'N') = 'N'
    and Trunc(p_creation_date) <= nvl(bl.expiration_date, p_creation_date)
    and p_creation_date >= bl.creation_date
    and bl.po_header_id = b.po_header_id
    and b.type_lookup_code = 'BLANKET'
    and b.approved_flag in ('Y','R')
    and nvl(b.cancel_flag, 'N') = 'N'
    and Trunc(p_creation_date)
         between nvl(b.start_date, Trunc(p_creation_date)) and nvl(b.end_date, p_creation_date);

  type pot_blkt_lines_tbl is TABLE Of pblines_cur%ROWTYPE;

  cursor pricebreaks_cur(p_po_line_id number
                        ,p_ship_to_location_id number
                        ,p_unit_price number
                        ,p_price_break_lookup_code varchar2
                        ,p_b_min number
                        ,p_bl_min number
                        ,p_amount_limit number
                        ,p_blanket_amt number
                        ,p_quantity number
                        ,p_line_qty number
                        ,p_line_all_qty number
                        ,p_creation_date date
                        ,p_need_by_date date)
     is
   select min(shipto_price) keep (dense_rank first order by nvl2(shipto_price, nvl(quantity, 0), null) desc nulls last, trunc(creation_date) desc) over () shipto_price,
          min(generic_price) keep (dense_rank first order by nvl2(generic_price, nvl(quantity, 0), null) desc nulls last, trunc(creation_date) desc) over () generic_price
   from
    (select
          (case when pb.ship_to_location_id = p_ship_to_location_id  and (pb.quantity is null or
             (p_price_break_lookup_code = 'NON CUMULATIVE' and p_quantity >= pb.quantity)
           or (p_price_break_lookup_code = 'CUMULATIVE' and p_quantity + p_line_qty >= pb.quantity ))
       then pb.price_override else null end) shipto_price,
          (case when pb.line_location_id is not null and pb.ship_to_location_id is null and (pb.quantity is null or
             (p_price_break_lookup_code = 'NON CUMULATIVE' and p_quantity >= pb.quantity)
           or (p_price_break_lookup_code = 'CUMULATIVE' and p_quantity + p_line_all_qty >= pb.quantity))
           then pb.price_override else null end) generic_price,
           creation_date,
           pb.quantity
      from po_line_locations_all pb
  where pb.po_line_id = p_po_line_id
  and pb.shipment_type = 'PRICE BREAK'
  and p_quantity * nvl(pb.price_override,p_unit_price) >= nvl(p_bl_min,0)
  and p_quantity * nvl(pb.price_override,p_unit_price) >= nvl(p_b_min,0)
  and trunc(nvl(p_need_by_date, p_creation_date)) between
            trunc(nvl(pb.start_date, pb.creation_date)) and
            nvl(pb.end_date, nvl(p_need_by_date, p_creation_date))
  and (p_amount_limit is null or p_quantity * nvl(pb.price_override,p_unit_price) + p_blanket_amt <= p_amount_limit) );

  l_pbline pblines_cur%ROWTYPE;
  l_qty number;
  l_shipto_price number;
  l_generic_price number;
  l_unit_price number;
  l_shipto_min number;
  l_generic_min number;
  l_unit_price_min number;
  l_shipto_po_header_id_min number;
  l_generic_po_header_id_min number;
  l_unit_po_header_id_min number;
  l_ret number := null;
  l_index number;
  l_debug_line number;
  l_ga_conversion_rate number;
begin
/*

   For blanket lines with price breaks, We store line-level price in the same row as price_override.  For blanket lines
     without price breaks, it stands in a seperate row by itself.  Therefore we can't use a where clause to exclude the price
     breaks in the former case, b/c that might remove a good line-level price in the 3nd step.  Note that a blanket line
     may not have any price break.  And a blanket line may not have any release shipment, either.  So both are outer joins.

   $$$$$$$$$$$$$$$$$$$$$$$$   Ordering criteria:
     >with price break
     order                     | Null ship-to  | Matching ship-to | Mis-matching ship-to
   _____________________________________________________________________________________
     Good price break quantity |   2           |        1         |           3
     Bad price break quantity  |   3           |        3         |           3
   _____________________________________________________________________________________
     >without price break (line level price)
     order: 3

   $$$$$$$$$$$$$$$$$$$$$$$$   line_qty and line_all_qty:
     for price breaks w/o ship_to_location specified, any shipment toward that blanket line counts as a price break ladder
     for price breaks w/ ship_to_location specified, only shipments with the exact ship_to_location counts.
     In PO Forms, ship_to_org is also considered simliarly, but we don't consider ship_to_org in our best price calculation.

   $$$$$$$$$$$$$$$$$$$$$$$$    rll.approved_flag:
     used in line_qty for price break ladder -- only approved release shipments count.  Not used in blanket_amt because you
     cannot exceed the blanekt total amount even if the obstacle is an unapproved shipment.  This is in accordance with
     Forms logic.

   $$$$$$$$$$$$$$$$$$$$$$$$   Assumptions:
     For a particular blanket line, the line level price is no smaller than any line on the price break.  This is important when
     blanket_amt (in amount term, not quantity) is considered.
     If a price break throws the blanket off the roof, its corresponding line price surely will. Thus it's safe to put them in
     the final where clause.
     For line_min and blanket_min, however, we could theoretically have the scenario when a price break is too small, but its
     line price is big enough to get over the MINs.  Although that will disallow us to use the line price, the penalty is small
     enough (quantity is small) and it's a corner case anyway.

*/

  if (g_po_distribution_id <> p_po_distribution_id) then

  g_po_distribution_id := p_po_distribution_id;

  g_hit_count := g_hit_count + 1;

  open pblines_cur(p_item_id,p_unit_meas_lookup_code,p_creation_date,p_currency_code);
  loop
    fetch pblines_cur into l_pbline;
    exit when pblines_cur%NOTFOUND;

        l_ga_conversion_rate := nvl(l_pbline.bl_rate, 1) * poa_ga_util_pkg.get_ga_conversion_rate(l_pbline.bl_func_cur_code, p_func_cur_code, p_rate_date); -- convert to blanket functional currency and then to standard PO functional currency

        if(l_pbline.global_agreement_flag = 'Y') then
           select
             sum(case when sll.approved_flag='Y' and sll.ship_to_location_id=p_ship_to_location_id then nvl(sd.quantity_ordered,0)-nvl(sd.quantity_cancelled,0) else 0 end) line_qty
             ,sum(case when sll.approved_flag='Y' then nvl(sd.quantity_ordered,0)-nvl(sd.quantity_cancelled,0) else 0 end) line_all_qty
             ,sum(sum(nvl(sll.price_override,0)*(nvl(sd.quantity_ordered,0)-nvl(sd.quantity_cancelled,0)))) over () blanket_amt
           into rline_q, rline_qa, rline_a
         from po_line_locations_all sll
             ,po_distributions_all sd
             ,po_lines_all pol
        where pol.po_line_id = sll.po_line_id (+)
          and pol.from_header_id = l_pbline.po_header_id
          and pol.from_line_id = l_pbline.po_line_id
          and sll.shipment_type (+) = 'STANDARD'
          and nvl(sd.distribution_type,'-99') <> 'AGREEMENT'
          and sll.line_location_id = sd.line_location_id(+)
          and sd.creation_date(+) < p_creation_date;

       else
          select
             sum(case when rll.approved_flag='Y' and rll.ship_to_location_id=p_ship_to_location_id then
                  nvl(rd.quantity_ordered,0)-nvl(rd.quantity_cancelled,0) else 0 end) line_qty
             ,sum(case when rll.approved_flag='Y' then
                  nvl(rd.quantity_ordered,0)-nvl(rd.quantity_cancelled,0) else 0 end) line_all_qty
             ,sum(sum(nvl(rll.price_override,0)*(nvl(rd.quantity_ordered,0)-nvl(rd.quantity_cancelled,0)))) over () blanket_amt
         into rline_q, rline_qa, rline_a
         from po_line_locations_all rll
             ,po_distributions_all rd
        where rll.po_header_id = l_pbline.po_header_id
          and rll.po_line_id = l_pbline.po_line_id
          and rll.shipment_type = 'BLANKET'
          and nvl(rd.distribution_type,'-99') <> 'AGREEMENT'
          and rll.line_location_id = rd.line_location_id(+)
          and rd.creation_date(+) < p_creation_date;

       end if;

          open pricebreaks_cur(l_pbline.po_line_id
                        ,p_ship_to_location_id
                        ,l_pbline.unit_price
                        ,l_pbline.price_break_lookup_code
                        ,nvl(l_pbline.b_min, 0)
                        ,nvl(l_pbline.bl_min, 0)
                        ,l_pbline.amount_limit
                        ,nvl(rline_a, 0)
                        ,p_quantity
                        ,nvl(rline_q, 0)
                        ,nvl(rline_qa, 0)
                        ,p_creation_date
                        ,p_need_by_date);
          fetch pricebreaks_cur into l_shipto_price, l_generic_price;
          close pricebreaks_cur;
          if(l_shipto_price is not null and (l_shipto_min is null or l_shipto_min > l_shipto_price * l_ga_conversion_rate)) then
            l_shipto_min := l_shipto_price * l_ga_conversion_rate;
            l_shipto_po_header_id_min := l_pbline.po_header_id;
          end if;
          if(l_generic_price is not null and (l_generic_min is null or l_generic_min > l_generic_price * l_ga_conversion_rate)) then
            l_generic_min := l_generic_price * l_ga_conversion_rate;
            l_generic_po_header_id_min := l_pbline.po_header_id;
          end if;

          l_unit_price := l_pbline.unit_price;
          if(l_unit_price is not null and (l_unit_price_min is null or l_unit_price_min > l_unit_price * l_ga_conversion_rate)) then
            if(p_quantity * l_unit_price >= nvl(l_pbline.bl_min,0)
              and p_quantity * l_unit_price >= nvl(l_pbline.b_min,0)
              and (l_pbline.amount_limit is null
                    or p_quantity * l_unit_price + nvl(rline_a, 0) <= l_pbline.amount_limit)) then
                l_unit_price_min := l_unit_price * l_ga_conversion_rate;
                l_unit_po_header_id_min := l_pbline.po_header_id;
            end if;
          end if;
  end loop;

  g_lowest_price := coalesce(l_shipto_min,l_generic_min,l_unit_price_min);
  g_blanket_id := coalesce(l_shipto_po_header_id_min, l_generic_po_header_id_min, l_unit_po_header_id_min);

  end if;

  return (case p_type
          when 'PRICE' then g_lowest_price
          when 'BLANKET' then g_blanket_id
          end);

END get_lowest_possible_price ;

END poa_dbi_savings_pkg;

/
