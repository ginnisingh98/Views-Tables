--------------------------------------------------------
--  DDL for Package Body QPR_WKFL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_WKFL_UTIL" AS
/* $Header: QPRUWKFLB.pls 120.10 2008/05/30 11:41:10 vinnaray ship $ */

QPR_NTFN_ITM_TYPE varchar2(30) := 'QPRDEAL';
g_cb_nfn_usr_ctr number ;
g_cb_usr_tbl char_type;
g_apst_nfn_usr_ctr number;
g_apst_usr_tbl char_type;

NL varchar2(1) := fnd_global.newline;
L_TABLE_STYLE VARCHAR2(100) := ' cellspacing="1" cellpadding="3" border="0" width="100%" bgcolor="white"';

L_TABLE_BOR_STYLE VARCHAR2(100) := ' cellspacing="1" cellpadding="3" border="1" width="100%"  bgcolor="white"';

L_TABLE_HEADER_STYLE VARCHAR2(100) := 'bgcolor="#cfe0f1" align=left';

L_TABLE_LABEL_STYLE VARCHAR2(100) := ' bgcolor="#cfe0f1" align=right ';

L_TABLE_CELL_STYLE VARCHAR2(100) := ' bgcolor="#f7f7e7" nowrap align=left ';

L_TABLE_CELL_WRAP_STYLE VARCHAR2(100) := ' align=left bgcolor="#f7f7e7" ';


type char240_type is table of varchar2(240) index by pls_integer;
type num_type is table of number index by pls_integer;

type LINE_DET_TYPE is record (
                            LINE_NUM char240_type,
                            PR_SEG_DESC char240_type,
                            PDT_DESC char240_type,
                            UOM char240_type,
                            ORD_QTY num_type,
                            LISTPRICE num_type,
                            PROPOSED_PRICE num_type,
                            REVISED_OQ num_type,
                            ONINV_PERC num_type,
                            INVPRICE num_type,
                            RECOMMEND_PRICE num_type,
                            INVPRICE_REV num_type,
                            TOTOFFADJ num_type,
                            POC_REV num_type,
                            UNIT_COST num_type,
                            MARGIN_AMT num_type,
                            MARGIN_PERC num_type,
                            LINE_SCORE num_type);

procedure approve_deal(
                        item_type in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2) is
l_resp_hdr_id number;
l_resp_user varchar2(500);
l_comments varchar2(2000);
l_app_complete varchar2(30);
l_ret_code varchar2(240):= fnd_api.g_ret_sts_success ;
begin

if funcmode = 'RUN' then

   l_resp_hdr_id := wf_engine.GetItemAttrNumber(item_type, itemkey,
                                        'QPR_PN_RESP_ID');
   l_resp_user := wf_engine.GetItemAttrText(item_type, itemkey,
                                        'QPR_FWD_TO_USR');

   l_comments := wf_engine.GetItemAttrText(item_type, itemkey,
                                           'QPR_COMMENTS');

    qpr_deal_approvals_pvt.process_user_action(l_resp_hdr_id,
                                               l_resp_user, 'APPROVE',
                                               l_comments, true,l_app_complete,
                                               l_ret_code
                                               );
   if l_ret_code = fnd_api.g_ret_sts_success then
     resultout := 'COMPLETE';
   else
      resultout := 'ERROR';
   end if;
else
  resultout := 'COMPLETE';
end if;

exception
when others then
  WF_CORE.CONTEXT ('QPR_WKFL_UTIL', 'approve_deal',
  item_type,itemkey, to_char(actid), funcmode);
  raise;
end approve_deal;

procedure reject_deal(
                      item_type in varchar2,
                      itemkey in varchar2,
                      actid in number,
                      funcmode in varchar2,
                      resultout out nocopy varchar2) is
l_resp_hdr_id number;
l_resp_user varchar2(500);
l_comments varchar2(2000);
l_app_complete varchar2(30);
l_ret_code varchar2(240):= fnd_api.g_ret_sts_success ;
begin

if funcmode = 'RUN' then

   l_resp_hdr_id := wf_engine.GetItemAttrNumber(item_type, itemkey,
                                        'QPR_PN_RESP_ID');
   l_resp_user := wf_engine.GetItemAttrText(item_type, itemkey,
                                        'QPR_FWD_TO_USR');

   l_comments := wf_engine.GetItemAttrText(item_type, itemkey,
                                           'QPR_COMMENTS');
    qpr_deal_approvals_pvt.process_user_action(l_resp_hdr_id,
                                               l_resp_user, 'REJECT',
                                               l_comments,true, l_app_complete,
                                               l_ret_code
                                               );
   if l_ret_code = fnd_api.g_ret_sts_success then
     resultout := 'COMPLETE';
   else
      resultout := 'ERROR';
   end if;
else
  resultout := 'COMPLETE';
end if;
exception
when others then
  WF_CORE.CONTEXT ('QPR_WKFL_UTIL', 'reject_deal',
  item_type,itemkey, to_char(actid), funcmode);
  raise;
end reject_deal;


procedure set_callback_nfn_details(
                                      item_type in varchar2,
                                      itemkey in varchar2,
                                      actid in number,
                                      funcmode in varchar2,
                                      resultout out nocopy varchar2) is

l_nid number;
l_response_id number;
l_to_user varchar2(240);
begin

if (funcmode  = 'RUN') then
  l_nid := wf_engine.context_nid;
  if g_cb_usr_tbl is not null then
    if g_cb_nfn_usr_ctr = -1 then
      g_cb_nfn_usr_ctr := g_cb_usr_tbl.first;
    else
      g_cb_nfn_usr_ctr :=  g_cb_nfn_usr_ctr  + 1;
    end if;
  end if;

  if g_cb_usr_tbl.exists(g_cb_nfn_usr_ctr) then
    l_to_user := g_cb_usr_tbl(g_cb_nfn_usr_ctr);
    wf_engine.SetItemAttrText(item_type, itemkey,
                          'QPR_FWD_TO_USR' , l_to_user);

    resultout := 'COMPLETE:COMPLETE';
  else
    resultout := 'ERROR';
  end if;
elsif (funcmode = 'SKIP') then
  resultout := wf_engine.eng_noskip;
else -- funcmode = 'CANCEL' / 'RETRY'
  resultout := 'COMPLETE:COMPLETE';
end if;

exception
when others then
  WF_CORE.CONTEXT ('QPR_WKFL_UTIL', 'set_callback_nfn_details',
  item_type,itemkey, to_char(actid), funcmode);
  raise;
end set_callback_nfn_details;

procedure set_app_status_nfn_details(
                                      item_type in varchar2,
                                      itemkey in varchar2,
                                      actid in number,
                                      funcmode in varchar2,
                                      resultout out nocopy varchar2) is

l_nid number;
l_response_id number;
l_to_user varchar2(240);
begin

if (funcmode  = 'RUN') then
  l_nid := wf_engine.context_nid;

  if g_apst_usr_tbl is not null then
    if g_apst_nfn_usr_ctr = -1 then
      g_apst_nfn_usr_ctr := g_apst_usr_tbl.first;
    else
      g_apst_nfn_usr_ctr :=  g_apst_nfn_usr_ctr  + 1;
    end if;
  end if;

  if g_apst_usr_tbl.exists(g_apst_nfn_usr_ctr) then
    l_to_user := g_apst_usr_tbl(g_apst_nfn_usr_ctr);
    wf_engine.SetItemAttrText(item_type, itemkey,
                          'QPR_FWD_TO_USR' , l_to_user);

    resultout := 'COMPLETE:COMPLETE';
  else
    resultout := 'ERROR';
  end if;
elsif (funcmode = 'SKIP') then
  resultout := wf_engine.eng_noskip;
else -- funcmode = 'CANCEL' / 'RETRY'
  resultout := 'COMPLETE:COMPLETE';
end if;

exception
when others then
  WF_CORE.CONTEXT ('QPR_WKFL_UTIL', 'set_app_status_nfn_details',
  item_type,itemkey, to_char(actid), funcmode);
  raise;
end set_app_status_nfn_details;

function print_heading(l_text in varchar2) return varchar2 is

   l_document varchar2(1000) := '';

   NL VARCHAR2(1) := fnd_global.newline;
   l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

begin

    l_document := '<TABLE width="100%" border=0 cellpadding=0 cellspacing=0 SUMMARY="">';
    l_document := l_document || '<TR>'||NL;
    l_document := l_document || '<TD class=subheader1><B>'|| l_text;
    l_document := l_document || '</B></TD></TR>';

        -- horizontal line
    l_document := l_document || '<TR>' || NL;
    l_document := l_document || '<TD colspan=2 height=1 bgcolor=#cccc99><img src=' || l_base_href
                  || '/OA_MEDIA/FNDITPNT.gif ALT=""></TD></TR>';

    l_document := l_document || '<TR><TD colspan=2 height=5>&nbsp</TR></TABLE>' || NL;

    return l_document;

end print_heading;

function get_table_label(p_content in varchar2) return varchar2
is
begin
  return( '<TD '|| L_TABLE_LABEL_STYLE || '> <B>' || p_content || '</B> &nbsp;</TD>' );
end get_table_label;

function get_table_cell(p_content in varchar2, p_wrap in boolean default false)
return varchar2 is
begin
  if p_wrap then
    return('<TD ' || L_TABLE_CELL_WRAP_STYLE ||'>' || p_content || '&nbsp; </TD>');
  else
    return('<TD ' || L_TABLE_CELL_STYLE ||'>' || p_content || ' &nbsp; </TD>');
  end if;
end get_table_cell;

function get_table_header(p_content in varchar2) return varchar2
is
begin
 return('<TD '|| L_TABLE_HEADER_STYLE || '><B>' || p_content || '</B>&nbsp;</TD>');
end get_table_header;

procedure form_deal_doc(p_response_header_id in number,
                        p_blob in out nocopy clob) is
l_hdr_score qpr_pn_response_hdrs.DEAL_HEADER_SCORE%type;
l_version_no qpr_pn_response_hdrs.VERSION_NUMBER%type;
l_ref_name varchar2(10000);
l_cus_name qpr_pn_request_hdrs_b.CUSTOMER_LONG_DESC%type;
l_rep_name qpr_pn_request_hdrs_b.SALES_REP_LONG_DESC%type;
l_hdr_curr qpr_pn_request_hdrs_b.currency_short_desc%type;
l_hdr_status qpr_pn_response_hdrs.response_status%type;
l_description qpr_pn_response_hdrs.description%type;
l_req_date qpr_pn_request_hdrs_b.deal_creation_date%type;
l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

l_document varchar2(32000);
l_request_hdr_id number;

t_line_det LINE_DET_TYPE;

b_first boolean := true;
l_rows number := 1000;

cursor c_line_details(p_precision number) is
select source_request_line_number,
      nvl((select name from qpr_pr_segments_all_vl
      where pr_segment_id = l.pr_segment_id
      and rownum < 2), l.pr_segment_id) pr_segment,
      l.inventory_item_short_desc,
      l.uom_code,
      l.ordered_qty,
      round(pr.listprice, p_precision),
      round(l.proposed_price, p_precision),
      l.revised_oq,
      round(decode(pr.listpricerev, 0, 0, (100 * pd.totoninv/pr.listpricerev)), p_precision),
      round(pr.invprice, p_precision),
      round(l.recommended_price, p_precision),
      round(pr.invpricerev, p_precision),
      round(pd.totoffinv, p_precision),
      round(pr.pocpricerev,p_precision ),
      round(pd.unit_cost, p_precision),
      round(pr.pocmarginamnt, p_precision),
      round(pr.pocmarginperc, p_precision),
      round(l.line_pricing_score, 2)
      from qpr_pn_lines l,
      (select response_header_id, pn_line_id,
        sum(decode(pn_pr_type_id, 1, amount, 0 )) listpricerev,
        sum(decode(pn_pr_type_id, 2, amount, 0 )) invpricerev,
        sum(decode(pn_pr_type_id, 3, amount, 0 )) pocpricerev,
        sum(decode(pn_pr_type_id, 4, amount, 0 )) pocmarginamnt,
        sum(decode(pn_pr_type_id, 1, unit_price, 0 )) listprice,
        sum(decode(pn_pr_type_id, 2, unit_price, 0 )) invprice,
        sum(decode(pn_pr_type_id, 3, unit_price, 0 )) pocprice,
        sum(decode(pn_pr_type_id, 4, unit_price, 0 )) pocmargin,
        sum(decode(pn_pr_type_id, 2, percent_price, 0 )) invpriceperc,
        sum(decode(pn_pr_type_id, 3, percent_price, 0 )) pocpriceperc,
        sum(decode(pn_pr_type_id, 4, percent_price, 0 )) pocmarginperc
        from qpr_pn_prices
        where pn_line_id is not null
        group by response_header_id, pn_line_id) pr,
      (select response_header_id, pn_line_id,
        sum(decode(erosion_type, 'ALL_COST', erosion_per_unit, 0 )) unit_cost,
        sum(decode(erosion_type, 'ALL_ONINVOICE',erosion_per_unit, 0) ) unit_oninv,
        sum(decode(erosion_type, 'ALL_OFFINVOICE', erosion_per_unit, 0 )) unit_offinv,
        sum(decode(erosion_type, 'ALL_COST', erosion_amount, 0 )) totcost,
        sum(decode(erosion_type, 'ALL_ONINVOICE',erosion_amount, 0) ) totoninv,
        sum(decode(erosion_type, 'ALL_OFFINVOICE', erosion_amount, 0 )) totoffinv
        from qpr_pn_pr_details
        where pn_line_id is not null
        and erosion_type like 'ALL_%'
        group by response_header_id, pn_line_id) pd
      where l.response_header_id = pd.response_header_id
      and l.pn_line_id = pd.pn_line_id
      and l.response_header_id = pr.response_header_id
      and l.pn_line_id = pr.pn_line_id
      and l.response_header_id = p_response_header_id
      order by l.response_header_id, l.pn_line_id;

l_std_precision number;
l_extnd_precision number;
l_min_amnt number;
l_precision number;
begin

  begin
  select round(resp.deal_header_score,2), resp.version_number,
        req.reference_name, req.customer_long_desc,
        req.sales_rep_long_desc, req.currency_short_desc,
        (select meaning from qpr_lookups
        where lookup_type = 'PN_STATUS'
        and lookup_code = resp.response_status and rownum < 2),
        resp.description, req.deal_creation_date , req.request_header_id
  into l_hdr_score, l_version_no, l_ref_name,
       l_cus_name, l_rep_name, l_hdr_curr, l_hdr_status,
       l_description, l_req_date, l_request_hdr_id
  from qpr_pn_response_hdrs resp, qpr_pn_request_hdrs_vl req
  where resp.response_header_id =  p_response_header_id
  and resp.request_header_id = req.request_header_id;
  exception
    when no_data_found then
      return;
  end;

  l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_href ||
                  '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;

  l_document := l_document || print_heading(fnd_message.get_String('QPR', 'QPR_DEAL_SUMMARY'));
  l_document := l_document || '<TABLE' || L_TABLE_STYLE || ' summary="">';
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_REQUEST_NO')) || NL;
  l_document := l_document || get_table_cell(l_request_hdr_id) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_CUSTOMER')) || NL;
  l_document := l_document || get_table_cell(l_cus_name) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR', 'QPR_REFERENCE')) || NL;
  l_document := l_document || get_table_cell(l_ref_name) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_STATUS')) || NL;
  l_document := l_document || get_table_cell(l_hdr_status) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_string('QPR', 'QPR_SCORE')) || NL;
  l_document := l_document || get_table_cell(l_hdr_score) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_SCENARIO')) || NL;
  l_document := l_document || get_table_cell(l_version_no) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_string('QPR', 'QPR_REQUESTOR')) || NL;
  l_document := l_document || get_table_cell(l_rep_name) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_string('QPR', 'QPR_REQ_DATE')) || NL;
  l_document := l_document || get_table_cell(l_req_date) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR', 'QPR_CURRENCY')) || NL;
  l_document := l_document || get_table_cell(l_hdr_curr) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR', 'QPR_DEAL_DESC'))|| NL;
  l_document := l_document || get_table_cell(l_description) || '</TR>' || NL;
  l_document := l_document ||'</TABLE>';
  l_document := l_document ||'</P>';

  Wf_notification.WriteToClob(p_blob, l_document);

  l_document := '';

  fnd_currency.get_info(l_hdr_curr, l_std_precision, l_extnd_precision,
                        l_min_amnt);
  if nvl(fnd_profile.value('QPR_REPORT_ROUNDING_PRECISION'),
          'STANDARD') = 'STANDARD' then
    l_precision := l_std_precision;
  else
    l_precision := l_extnd_precision;
  end if;

  open c_line_details(l_precision);
  loop
    fetch c_line_details bulk collect into t_line_det limit l_rows;
    exit when t_line_det.LINE_NUM.count = 0;
    if b_first then
      l_document := l_document || '<TABLE' || L_TABLE_BOR_STYLE || ' summary="">';
      l_document := l_document || '<TR>';
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_LINE_NO'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_SEGMENT'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_PRODUCT'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_UOM'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_PROPOSED_VOL'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_LIST_PRICE'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_PROPOSED_PRICE'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_REVISED_VOLUME'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_ONADJ_PERC'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_REVISED_PRICE'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_RECOMMEND_PRICE'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_INV_REV'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_OFFADJ_AMT'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_POC_REV'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_UNIT_COST'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_MAR_AMT'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_MAR_PERC'))|| NL;
      l_document := l_document || get_table_header(fnd_message.get_String('QPR','QPR_LINE_SCORE'))|| NL;
      l_document := l_document || '</TR>';

      Wf_notification.WriteToClob(p_blob, l_document);
      b_first := false;
      l_document := '';
    end if;

    for i in t_line_det.LINE_NUM.first..t_line_det.LINE_NUM.last loop
      l_document := '';
      l_document := l_document || '<TR>';
      l_document := l_document || get_table_cell(t_line_det.LINE_NUM(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.PR_SEG_DESC(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.PDT_DESC(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.UOM(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.ORD_QTY(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.LISTPRICE(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.PROPOSED_PRICE(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.REVISED_OQ(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.ONINV_PERC(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.INVPRICE(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.RECOMMEND_PRICE(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.INVPRICE_REV(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.TOTOFFADJ(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.POC_REV(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.UNIT_COST(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.MARGIN_AMT(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.MARGIN_PERC(i), true) ||  NL;
      l_document := l_document || get_table_cell(t_line_det.LINE_SCORE(i), true) ||  NL;
      l_document := l_document || '</TR>';

      Wf_notification.WriteToClob(p_blob, l_document);
    end loop;

    t_line_det.LINE_NUM.delete;
    t_line_det.PR_SEG_DESC.delete;
    t_line_det.PDT_DESC.delete;
    t_line_det.UOM.delete;
    t_line_det.ORD_QTY.delete;
    t_line_det.LISTPRICE.delete;
    t_line_det.PROPOSED_PRICE.delete;
    t_line_det.REVISED_OQ.delete;
    t_line_det.ONINV_PERC.delete;
    t_line_det.INVPRICE.delete;
    t_line_det.RECOMMEND_PRICE.delete;
    t_line_det.INVPRICE_REV.delete;
    t_line_det.TOTOFFADJ.delete;
    t_line_det.POC_REV.delete;
    t_line_det.UNIT_COST.delete;
    t_line_det.MARGIN_AMT.delete;
    t_line_det.MARGIN_PERC.delete;
    t_line_det.LINE_SCORE.delete;
  end loop;

  -- if line was never executed then b_first will be true
  -- we need not add closing tag
  if not b_first then
      Wf_notification.WriteToClob(p_blob, '</TABLE>');
  end if;
end form_deal_doc;

procedure show_deal_details(document_id in varchar2,
                            display_type in varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2) is


l_resp_hdr_id number;
l_document varchar2(32000) := '';

l_hdr_score qpr_pn_response_hdrs.DEAL_HEADER_SCORE%type;
l_version_no qpr_pn_response_hdrs.VERSION_NUMBER%type;
l_ref_name varchar2(10000);
l_cus_name qpr_pn_request_hdrs_b.CUSTOMER_LONG_DESC%type;
l_rep_name qpr_pn_request_hdrs_b.SALES_REP_LONG_DESC%type;
l_hdr_curr qpr_pn_request_hdrs_b.currency_short_desc%type;
l_hdr_status qpr_pn_response_hdrs.response_status%type;
l_description qpr_pn_response_hdrs.description%type;
l_req_date qpr_pn_request_hdrs_b.deal_creation_date%type;

l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');
l_url varchar2(1000);
l_hdr_msg varchar2(2000);
l_request_hdr_id number;
begin

l_resp_hdr_id := to_number(document_id);
begin
  select round(resp.deal_header_score, 2), resp.version_number,
        req.reference_name, req.customer_long_desc,
        req.sales_rep_long_desc, req.currency_short_desc,
        (select meaning from qpr_lookups
        where lookup_type = 'PN_STATUS'
        and lookup_code = resp.response_status and rownum < 2),
        resp.description, req.deal_creation_date ,
        resp.request_header_id
  into l_hdr_score, l_version_no, l_ref_name,
       l_cus_name, l_rep_name, l_hdr_curr, l_hdr_status,
       l_description, l_req_date, l_request_hdr_id
  from qpr_pn_response_hdrs resp, qpr_pn_request_hdrs_vl req
  where resp.response_header_id = l_resp_hdr_id
  and resp.request_header_id = req.request_header_id;
  exception
    when no_data_found then
      return;
  end;


 l_url := l_base_href ||
  '/OA_HTML/OA.jsp?OAFunc=QPR_DEAL_WORKBENCH&RESPONSE_HEADER_ID=' || l_resp_hdr_id || '&READ_ONLY=True&RESET=True';

/*
  fnd_message.set_name('QPR', 'QPR_DEAL_APP');
  fnd_message.set_token('DEAL_ID', l_resp_hdr_id);
  l_hdr_msg := fnd_message.get;*/

if display_type = 'text/html' then
--  l_document := l_document || '<BR>' || l_hdr_msg || NL;
  l_document := l_document || '<BR>';
  l_document := l_document || NL || '<!-- DEAL SUMMARY -->'|| NL || NL ||  '<P>';
  l_document := l_document || print_heading(fnd_message.get_String('QPR', 'QPR_DEAL_SUMMARY'));
  l_document := l_document || '<TABLE' || L_TABLE_STYLE || ' summary="">';
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_REQUEST_NO')) || NL;
  l_document := l_document || get_table_cell(l_request_hdr_id) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_CUSTOMER')) || NL;
  l_document := l_document || get_table_cell(l_cus_name) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR', 'QPR_REFERENCE')) || NL;
  l_document := l_document || get_table_cell(l_ref_name) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_STATUS')) || NL;
  l_document := l_document || get_table_cell(l_hdr_status) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_string('QPR', 'QPR_SCORE')) || NL;
  l_document := l_document || get_table_cell(l_hdr_score) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR','QPR_SCENARIO')) || NL;
  l_document := l_document || get_table_cell(l_version_no) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_string('QPR', 'QPR_REQUESTOR')) || NL;
  l_document := l_document || get_table_cell(l_rep_name) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_string('QPR', 'QPR_REQ_DATE')) || NL;
  l_document := l_document || get_table_cell(l_req_date) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR', 'QPR_CURRENCY')) || NL;
  l_document := l_document || get_table_cell(l_hdr_curr) || '</TR>' || NL;
  l_document := l_document || '<TR>' || get_table_label(fnd_message.get_String('QPR', 'QPR_DEAL_DESC'))|| NL;
  l_document := l_document || get_table_cell(l_description) || '</TR>' || NL;
  l_document := l_document ||'</TABLE>';
  l_document := l_document ||'</P>';
  l_document := l_document || '<P>' || '<a href="' || l_url || '">' || fnd_message.get_String('QPR', 'QPR_DEAL_URL')||'<a>';
  l_document := l_document || '<BR>';
  document := l_document;
else
  l_document := l_document || NL;
--  l_document := l_document || l_hdr_msg || NL || NL;
  l_document := l_document || fnd_message.get_String('QPR', 'QPR_DEAL_SUMMARY') || NL;
  l_document := l_document || fnd_message.get_String('QPR','QPR_REQUEST_NO') || ': ' || l_request_hdr_id || NL;
  l_document := l_document || fnd_message.get_String('QPR','QPR_CUSTOMER') || ': ' || l_cus_name || NL;
  l_document := l_document || fnd_message.get_String('QPR', 'QPR_REFERENCE') || ': ' || l_ref_name || NL;
  l_document := l_document || fnd_message.get_String('QPR','QPR_STATUS') || ': ' || l_hdr_status || NL;
  l_document := l_document || fnd_message.get_string('QPR', 'QPR_SCORE') || ': ' || l_hdr_score || NL;
  l_document := l_document || fnd_message.get_String('QPR','QPR_SCENARIO') || ': ' || l_version_no|| NL;
  l_document := l_document || fnd_message.get_string('QPR', 'QPR_REQUESTOR') || ': ' || l_rep_name|| NL;
  l_document := l_document || fnd_message.get_string('QPR', 'QPR_REQ_DATE') || ': ' || l_req_date || NL;
  l_document := l_document || fnd_message.get_String('QPR', 'QPR_CURRENCY') || ': ' || l_hdr_curr || NL;
  l_document := l_document || fnd_message.get_String('QPR', 'QPR_DEAL_DESC')|| ': ' || l_description || NL;
  l_document := l_document || fnd_message.get_String('QPR', 'QPR_DEAL_URL')|| ':' || l_url || NL;
  document := l_document;
end if;

exception
  when others then
    wf_core.context('qpr_wkfl_util'
                   ,'show_deal_details'
                   ,document_id
                   ,display_type);
    raise;
end show_deal_details;

procedure attach_deal_details (
                               document_id   in varchar2,
                               display_type  in varchar2,
                               document      in out nocopy clob,
                               document_type in out nocopy varchar2
                              ) is
  lob_id       number;
  bdoc         blob;
  content_type varchar2(100);
  filename     varchar2(300);
begin
  lob_id := to_number(document_id);

  document_type := Wf_Notification.doc_html;

  form_deal_doc(lob_id, document);

exception
  when others then
    wf_core.context('qpr_wkfl_util'
                   ,'attach_deal_details'
                   ,document_id
                   ,display_type);
    raise;
end attach_deal_details;

procedure invoke_toapp_nfn_process(p_response_id in number,
                                    p_fwd_to_user in varchar2,
                                    retcode out nocopy number,
                                    errbuf out nocopy varchar2) is
l_item_key varchar2(240);
l_process_name varchar2(240) := 'QPRTAPPNFNP';
l_current_user varchar2(500);
l_deal_url varchar2(1000);
l_request_hdr_id number;
l_version_no number;
l_init_key varchar2(240);
l_end_date date;
l_ct number;
begin

  select user_name into l_current_user
  from fnd_user
  where user_id = fnd_global.user_id;

  select request_header_id, version_number
  into l_request_hdr_id, l_version_no
  from qpr_pn_response_hdrs
  where response_header_id = p_response_id
  and rownum < 2;

  l_init_key := 'TOAPP_' || p_response_id || p_fwd_to_user;

  begin
    select item_key, end_date
    into l_item_key, l_end_date
    from
    (select item_key, end_date
    from wf_items where item_type = QPR_NTFN_ITM_TYPE
    and item_key like (l_init_key || '%')
    order by begin_date desc)
    where rownum < 2;
    if l_end_date is null then
      retcode := 2;
      errbuf := 'Unable to invoke workflow notification process.' ||
                'Active notification exists.';
      return;
    else
      l_ct := to_number(nvl(substrb(l_item_key, length(l_init_key)+2), '0')) + 1;
    end if;
  exception
    when no_data_found then
      l_ct := 0;
  end;

  l_item_key := l_init_key || '_' || l_ct;

  wf_engine.CreateProcess(QPR_NTFN_ITM_TYPE ,l_item_key , l_process_name,
                        p_response_id, l_current_user);

  wf_engine.SetItemAttrText(QPR_NTFN_ITM_TYPE , l_item_key,
                          'QPR_FWD_TO_USR' , p_fwd_to_user);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_PN_RESP_ID',
                                p_response_id);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_REQUEST_HDR_ID',
                                l_request_hdr_id);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_SCENARIO_NO',
                                l_version_no);

  wf_engine.StartProcess(QPR_NTFN_ITM_TYPE , l_item_key);

exception
  when others then
    retcode := 2;
    errbuf := 'Unable to create workflow notification process';
end invoke_toapp_nfn_process;

procedure complete_toapp_nfn_process(p_response_id in number,
                                     p_current_user in varchar2,
                                     p_status in varchar2,
                                     retcode out nocopy number,
                                     errbuf out nocopy varchar2) is
l_item_key varchar2(240);
l_activity_name wf_process_activities.activity_name%type;
l_status varchar2(240);
l_init_key varchar2(240);
begin
  l_init_key := 'TOAPP_' || p_response_id || p_current_user;

-- Done with the assumption that there will be only one active item for
-- key l_init_key --
  begin
    select item_key into l_item_key
    from wf_items
    where item_type = QPR_NTFN_ITM_TYPE
    and item_key like (l_init_key || '%')
    and end_date is null
    and rownum < 2;
  exception
    when no_data_found then
      return;
  end;

  select pa.activity_name  into l_activity_name
  from WF_ITEM_ACTIVITY_STATUSES act,  wf_process_activities pa
  where act.item_type = QPR_NTFN_ITM_TYPE
  and act.item_key = l_item_key
  and act.activity_status = 'NOTIFIED'
  and act.process_activity = pa.instance_id
  and rownum < 2;

  if p_status = 'APPROVE' then
    l_status := 'APPROVED';
  elsif p_status = 'REJECT' then
    l_status := 'REJECTED';
  end if;

  wf_engine.CompleteActivity(QPR_NTFN_ITM_TYPE, l_item_key,
                                l_activity_name, l_status );

exception
  when others then
    retcode := 2;
    errbuf := 'Unable to complete workflow notification process';
end complete_toapp_nfn_process;

procedure cancel_toapp_nfn_process(p_response_id in number,
                                   p_usr_list in char_type,
                                     retcode out nocopy number,
                                     errbuf out nocopy varchar2) is
l_item_key varchar2(240);
l_init_key varchar2(240);
begin

  if p_usr_list.count = 0 then
    return;
  end if;

  for i in p_usr_list.first..p_usr_list.last loop

    l_init_key := 'TOAPP_' || p_response_id || p_usr_list(i);

  -- Done with the assumption that there will be only one active item for
  -- key l_init_key --
    begin
      select item_key into l_item_key
      from wf_items
      where item_type = QPR_NTFN_ITM_TYPE
      and item_key like (l_init_key || '%')
      and end_date is null
      and rownum < 2;

      wf_engine.AbortProcess(QPR_NTFN_ITM_TYPE, l_item_key,
                                    null , WF_ENGINE.eng_null);
    exception
      when no_data_found then
        null;
    end;
  end loop;

exception
  when others then
    retcode := 2;
    errbuf := 'Unable to cancel workflow notification process';
end cancel_toapp_nfn_process;


procedure invoke_cb_nfn_process(p_response_id in number,
                                p_usr_list in char_type,
                                p_comments in varchar2,
                                  retcode out nocopy number,
                                  errbuf out nocopy varchar2)
is
l_item_key varchar2(240);
l_process_name varchar2(240) := 'QPRCBNFNP';
l_current_user varchar2(500);
l_to_user varchar2(500);
l_request_hdr_id number;
l_version_no number;
begin
  select user_name into l_current_user
  from fnd_user
  where user_id = fnd_global.user_id;

  select request_header_id, version_number
  into l_request_hdr_id, l_version_no
  from qpr_pn_response_hdrs
  where response_header_id = p_response_id
  and rownum < 2;

  if p_usr_list.count = 0 then
    return;
  end if;

  g_cb_nfn_usr_ctr := -1;

	if g_cb_usr_tbl is not null then
		g_cb_usr_tbl.delete;
	end if;

  for i in p_usr_list.first..p_usr_list.last loop
    g_cb_usr_tbl(i) := p_usr_list(i);
  end loop;
  l_item_key := 'CALLBACK_' || p_response_id || l_current_user || sysdate;

  wf_engine.CreateProcess(QPR_NTFN_ITM_TYPE ,l_item_key , l_process_name,
                        p_response_id,l_current_user);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_PN_RESP_ID',
                                p_response_id);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_REQUEST_HDR_ID',
                                l_request_hdr_id);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_SCENARIO_NO',
                                l_version_no);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key,'QPR_NUM_OF_USERS',
                                g_cb_usr_tbl.count);

  wf_engine.SetItemAttrText(QPR_NTFN_ITM_TYPE , l_item_key,'QPR_FROM_USER',
                                          l_current_user);

  wf_engine.SetItemAttrText(QPR_NTFN_ITM_TYPE , l_item_key,'QPR_COMMENTS',
                                          p_comments);

  wf_engine.StartProcess(QPR_NTFN_ITM_TYPE , l_item_key);

exception
  when others then
    retcode := 2;
    errbuf := 'Unable to create workflow notification process';
end invoke_cb_nfn_process;

procedure invoke_appstat_nfn_process(p_response_id in number,
                                  p_usr_list in char_type,
                                  p_comments in varchar2,
                                  p_status in varchar2,
                                  retcode out nocopy number,
                                  errbuf out nocopy varchar2)
is
l_item_key varchar2(240);
l_process_name varchar2(240) := 'QPRAPPSTATNFNP';
l_current_user varchar2(500);
l_to_user varchar2(500);
l_request_hdr_id number;
l_version_no number;
l_status varchar2(240);

begin
  select user_name into l_current_user
  from fnd_user
  where user_id = fnd_global.user_id;

  select request_header_id, version_number
  into l_request_hdr_id, l_version_no
  from qpr_pn_response_hdrs
  where response_header_id = p_response_id
  and rownum < 2;

  if p_usr_list.count = 0 then
    return;
  end if;

  g_apst_nfn_usr_ctr := -1;

	if g_apst_usr_tbl is not null then
		g_apst_usr_tbl.delete;
	end if;

  for i in p_usr_list.first..p_usr_list.last loop
    g_apst_usr_tbl(i) := p_usr_list(i);
  end loop;

  l_item_key := 'APPSTAT_' || p_response_id || l_current_user || sysdate;

  wf_engine.CreateProcess(QPR_NTFN_ITM_TYPE ,l_item_key , l_process_name,
                        p_response_id, l_current_user);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_PN_RESP_ID',
                                p_response_id);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_REQUEST_HDR_ID',
                                l_request_hdr_id);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key, 'QPR_SCENARIO_NO',
                                l_version_no);

  wf_engine.SetItemAttrNumber(QPR_NTFN_ITM_TYPE , l_item_key,'QPR_NUM_OF_USERS',
                                g_apst_usr_tbl.count);

  wf_engine.SetItemAttrText(QPR_NTFN_ITM_TYPE , l_item_key,'QPR_FROM_USER',
                                          l_current_user);

  wf_engine.SetItemAttrText(QPR_NTFN_ITM_TYPE , l_item_key,'QPR_COMMENTS',
                                          p_comments);

  if p_status = 'APPROVE' then
    select meaning into l_status from qpr_lookups where lookup_type = 'AME_STATUS'
    and lookup_code = p_status;

    wf_engine.SetItemAttrText(QPR_NTFN_ITM_TYPE, l_item_key,'QPR_PN_RESP_STATUS',
                              l_status);
  elsif p_status = 'REJECT' then
    select meaning into l_status from qpr_lookups where lookup_type = 'AME_STATUS'
    and lookup_code = p_status;

    wf_engine.SetItemAttrText(QPR_NTFN_ITM_TYPE, l_item_key,'QPR_PN_RESP_STATUS',
                              l_status);

  end if;

  wf_engine.StartProcess(QPR_NTFN_ITM_TYPE , l_item_key);

exception
  when others then
    retcode := 2;
    errbuf := 'Unable to create workflow notification process';
end invoke_appstat_nfn_process;


END;


/
