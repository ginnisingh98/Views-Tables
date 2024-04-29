--------------------------------------------------------
--  DDL for Package Body ICX_MARGIN_WEB_ANA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_MARGIN_WEB_ANA_PKG" as
/* $Header: ICXCSMRB.pls 115.0 99/08/09 17:23:22 porting ship $ */
--
--
procedure BUILD_ICX_CST_MARGIN_TABLE AS
records_processed number;
sum_margin cst_margin_temp.margin%TYPE;
CURSOR wkly_amt_cursor IS
SELECT
	cmt.build_id,
	cmt.customer_id,
	cmt.primary_salesrep_id,
	cmt.territory_id,
	cmt.inventory_item_id,
	cmt.org_id,
	cmt.sold_to_customer_name,
	sum(invoiced_amount) sum_inv_amt,
	sum(cogs_amount) sum_cogs_amt
FROM
	CST_MARGIN_TEMP cmt,
	CST_MARGIN_BUILD cmb
WHERE
	cmt.build_id = cmb.build_id AND
	cmt.gl_date >= cmb.to_date - 7 AND
	cmt.build_id = (select max(build_id) from cst_margin_temp)
GROUP BY
	cmt.build_id,
	cmt.customer_id,
	cmt.primary_salesrep_id,
	cmt.territory_id,
	cmt.inventory_item_id,
	cmt.org_id,
	cmt.sold_to_customer_name
;
CURSOR mnthly_amt_cursor IS
SELECT
	cmt.build_id,
	cmt.customer_id,
	cmt.primary_salesrep_id,
	cmt.territory_id,
	cmt.inventory_item_id,
	cmt.org_id,
	cmt.sold_to_customer_name,
	sum(invoiced_amount) sum_inv_amt,
	sum(cogs_amount) sum_cogs_amt
FROM
	CST_MARGIN_TEMP cmt,
	CST_MARGIN_BUILD cmb
WHERE
	cmt.build_id = cmb.build_id AND
	cmt.gl_date >= cmb.to_date - 30 AND
	cmt.build_id = (select max(build_id) from cst_margin_temp)
GROUP BY
	cmt.build_id,
	cmt.customer_id,
	cmt.primary_salesrep_id,
	cmt.territory_id,
	cmt.inventory_item_id,
	cmt.org_id,
	cmt.sold_to_customer_name
;
CURSOR qrtrly_amt_cursor IS
SELECT
	cmt.build_id,
	cmt.customer_id,
	cmt.primary_salesrep_id,
	cmt.territory_id,
	cmt.inventory_item_id,
	cmt.org_id,
	cmt.sold_to_customer_name,
	sum(invoiced_amount) sum_inv_amt,
	sum(cogs_amount) sum_cogs_amt
FROM
	CST_MARGIN_TEMP cmt,
	CST_MARGIN_BUILD cmb
WHERE
	cmt.build_id = cmb.build_id AND
	cmt.gl_date >= cmb.to_date - 90 AND
	cmt.build_id = (select max(build_id) from cst_margin_temp)
GROUP BY
	cmt.build_id,
	cmt.customer_id,
	cmt.primary_salesrep_id,
	cmt.territory_id,
	cmt.inventory_item_id,
	cmt.org_id,
	cmt.sold_to_customer_name
;
--
BEGIN

--
/*   delete date from tables   */
DELETE FROM ICX_MARGIN_ANALYSIS;
DELETE FROM ICX_MARGIN_ANALYSIS_ERR;

records_processed := 0;
FOR wkly_amt_rec IN wkly_amt_cursor LOOP
--
  declare
  tmp_build_id CST_MARGIN_TEMP.build_id%TYPE;
  tmp_customer_id CST_MARGIN_TEMP.customer_id%TYPE;
  tmp_pri_salesrep_id CST_MARGIN_TEMP.primary_salesrep_id%TYPE;
  tmp_territory_id CST_MARGIN_TEMP.territory_id%TYPE;
  tmp_inv_item_id CST_MARGIN_TEMP.inventory_item_id%TYPE;
--
  begin
    tmp_build_id := wkly_amt_rec.build_id;
    tmp_customer_id := wkly_amt_rec.customer_id;
    tmp_pri_salesrep_id := wkly_amt_rec.primary_salesrep_id;
    tmp_territory_id := wkly_amt_rec.territory_id;
    tmp_inv_item_id := wkly_amt_rec.inventory_item_id;

if wkly_amt_rec.sum_inv_amt is null then
  wkly_amt_rec.sum_inv_amt := 0;
end if;

if wkly_amt_rec.sum_cogs_amt is null then
  wkly_amt_rec.sum_cogs_amt := 0;
end if;

  sum_margin :=	wkly_amt_rec.sum_inv_amt - wkly_amt_rec.sum_cogs_amt;

  INSERT INTO icx_margin_analysis
	(
	build_id,
	customer_id,
	primary_salesrep_id,
	territory_id,
	inventory_item_id,
	org_id,
	sold_to_customer_name,
	invoiced_amount,
	cogs_amount,
	margin,
	period
	)
  VALUES
	(
	wkly_amt_rec.build_id,
	wkly_amt_rec.customer_id,
	wkly_amt_rec.primary_salesrep_id,
	wkly_amt_rec.territory_id,
	wkly_amt_rec.inventory_item_id,
	wkly_amt_rec.org_id,
	wkly_amt_rec.sold_to_customer_name,
	wkly_amt_rec.sum_inv_amt,
	wkly_amt_rec.sum_cogs_amt,
	sum_margin,
	'7D'
	);

    records_processed := records_processed + 1;
    if (records_processed = 100) then
      COMMIT;
      records_processed := 0;
    end if;

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        INSERT into icx_margin_analysis_err
          (
          build_id,
          customer_id,
          primary_salesrep_id,
	  territory_id,
          inventory_item_id,
          period
          )
        VALUES
          (
          tmp_build_id,
          tmp_customer_id,
          tmp_pri_salesrep_id,
	  tmp_territory_id,
          tmp_inv_item_id,
          '7D'
          );
      WHEN OTHERS THEN
        INSERT into icx_margin_analysis_err
          (
          build_id,
          customer_id,
          primary_salesrep_id,
	  territory_id,
          inventory_item_id,
          period
          )
        VALUES
          (
          tmp_build_id,
          tmp_customer_id,
          tmp_pri_salesrep_id,
	  tmp_territory_id,
          tmp_inv_item_id,
          '7D'
          );
  end;

end loop;


records_processed := 0;
FOR mnthly_amt_rec IN mnthly_amt_cursor LOOP
--
  declare
  tmp_build_id CST_MARGIN_TEMP.build_id%TYPE;
  tmp_customer_id CST_MARGIN_TEMP.customer_id%TYPE;
  tmp_pri_salesrep_id CST_MARGIN_TEMP.primary_salesrep_id%TYPE;
  tmp_territory_id CST_MARGIN_TEMP.territory_id%TYPE;
  tmp_inv_item_id CST_MARGIN_TEMP.inventory_item_id%TYPE;
--
  begin
    tmp_build_id := mnthly_amt_rec.build_id;
    tmp_customer_id := mnthly_amt_rec.customer_id;
    tmp_pri_salesrep_id := mnthly_amt_rec.primary_salesrep_id;
    tmp_territory_id := mnthly_amt_rec.territory_id;
    tmp_inv_item_id := mnthly_amt_rec.inventory_item_id;

if mnthly_amt_rec.sum_inv_amt is null then
  mnthly_amt_rec.sum_inv_amt := 0;
end if;

if mnthly_amt_rec.sum_cogs_amt is null then
  mnthly_amt_rec.sum_cogs_amt := 0;
end if;

  sum_margin :=	mnthly_amt_rec.sum_inv_amt - mnthly_amt_rec.sum_cogs_amt;

  INSERT INTO icx_margin_analysis
	(
	build_id,
	customer_id,
	primary_salesrep_id,
	territory_id,
	inventory_item_id,
	org_id,
	sold_to_customer_name,
	invoiced_amount,
	cogs_amount,
	margin,
	period
	)
  VALUES
	(
	mnthly_amt_rec.build_id,
	mnthly_amt_rec.customer_id,
	mnthly_amt_rec.primary_salesrep_id,
	mnthly_amt_rec.territory_id,
	mnthly_amt_rec.inventory_item_id,
	mnthly_amt_rec.org_id,
	mnthly_amt_rec.sold_to_customer_name,
	mnthly_amt_rec.sum_inv_amt,
	mnthly_amt_rec.sum_cogs_amt,
	sum_margin,
	'30D'
	);

    records_processed := records_processed + 1;
    if (records_processed = 100) then
      COMMIT;
      records_processed := 0;
    end if;

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        INSERT into icx_margin_analysis_err
          (
          build_id,
          customer_id,
          primary_salesrep_id,
	  territory_id,
          inventory_item_id,
          period
          )
        VALUES
          (
          tmp_build_id,
          tmp_customer_id,
          tmp_pri_salesrep_id,
	  tmp_territory_id,
          tmp_inv_item_id,
          '30D'
          );
      WHEN OTHERS THEN
        INSERT into icx_margin_analysis_err
          (
          build_id,
          customer_id,
          primary_salesrep_id,
	  territory_id,
          inventory_item_id,
          period
          )
        VALUES
          (
          tmp_build_id,
          tmp_customer_id,
          tmp_pri_salesrep_id,
	  tmp_territory_id,
          tmp_inv_item_id,
          '30D'
          );
  end;

end loop;


records_processed := 0;
FOR qrtrly_amt_rec IN qrtrly_amt_cursor LOOP
--
  declare
  tmp_build_id CST_MARGIN_TEMP.build_id%TYPE;
  tmp_customer_id CST_MARGIN_TEMP.customer_id%TYPE;
  tmp_pri_salesrep_id CST_MARGIN_TEMP.primary_salesrep_id%TYPE;
  tmp_territory_id CST_MARGIN_TEMP.territory_id%TYPE;
  tmp_inv_item_id CST_MARGIN_TEMP.inventory_item_id%TYPE;
--
  begin
    tmp_build_id := qrtrly_amt_rec.build_id;
    tmp_customer_id := qrtrly_amt_rec.customer_id;
    tmp_pri_salesrep_id := qrtrly_amt_rec.primary_salesrep_id;
    tmp_territory_id := qrtrly_amt_rec.territory_id;
    tmp_inv_item_id := qrtrly_amt_rec.inventory_item_id;

if qrtrly_amt_rec.sum_inv_amt is null then
  qrtrly_amt_rec.sum_inv_amt := 0;
end if;

if qrtrly_amt_rec.sum_cogs_amt is null then
  qrtrly_amt_rec.sum_cogs_amt := 0;
end if;

  sum_margin :=	qrtrly_amt_rec.sum_inv_amt - qrtrly_amt_rec.sum_cogs_amt;

  INSERT INTO icx_margin_analysis
	(
	build_id,
	customer_id,
	primary_salesrep_id,
	territory_id,
	inventory_item_id,
	org_id,
	sold_to_customer_name,
	invoiced_amount,
	cogs_amount,
	margin,
	period
	)
  VALUES
	(
	qrtrly_amt_rec.build_id,
	qrtrly_amt_rec.customer_id,
	qrtrly_amt_rec.primary_salesrep_id,
	qrtrly_amt_rec.territory_id,
	qrtrly_amt_rec.inventory_item_id,
	qrtrly_amt_rec.org_id,
	qrtrly_amt_rec.sold_to_customer_name,
	qrtrly_amt_rec.sum_inv_amt,
	qrtrly_amt_rec.sum_cogs_amt,
	sum_margin,
	'90D'
	);

    records_processed := records_processed + 1;
    if (records_processed = 100) then
      COMMIT;
      records_processed := 0;
    end if;

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        INSERT into icx_margin_analysis_err
          (
          build_id,
          customer_id,
          primary_salesrep_id,
	  territory_id,
          inventory_item_id,
          period
          )
        VALUES
          (
          tmp_build_id,
          tmp_customer_id,
          tmp_pri_salesrep_id,
	  tmp_territory_id,
          tmp_inv_item_id,
          '90D'
          );
      WHEN OTHERS THEN
        INSERT into icx_margin_analysis_err
          (
          build_id,
          customer_id,
          primary_salesrep_id,
	  territory_id,
          inventory_item_id,
          period
          )
        VALUES
          (
          tmp_build_id,
          tmp_customer_id,
          tmp_pri_salesrep_id,
	  tmp_territory_id,
          tmp_inv_item_id,
          '90D'
          );
  end;
end loop;

COMMIT;

end BUILD_ICX_CST_MARGIN_TABLE;


--		ICX_GET_TOTAL_SALES ==> returns the sum of the invoiced_amounts from the
--					CST_MARGIN_WEB_ANALYSIS table based on the period passed in
--
function icx_get_total_sales (in_period in varchar2) return number as
  tot_inv_amount number;
begin
select sum(invoiced_amount)
  into tot_inv_amount
  from icx_margin_analysis
  where period=in_period;
return (tot_inv_amount);
end icx_get_total_sales;
--

--		ICX_GET_TOTAL_MARGIN ==>returns the sum of the margins from the
--					CST_MARGIN_WEB_ANALYSIS table based on the period passed in
--
function icx_get_total_margin (in_period in varchar2) return number as
 tot_margin_amount number;
begin
select sum(margin)
  into tot_margin_amount
  from icx_margin_analysis
  where period=in_period;
return  tot_margin_amount;
end icx_get_total_margin;
--
function GET_ITEM_NUMBER (in_ITEM_ID in number)
  return VARCHAR2 as
  temp_item_num MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
begin
select distinct concatenated_segments
  into temp_item_num
  from mtl_system_items_kfv
  where inventory_item_id = in_item_id;
  return (temp_item_num);
exception
when too_many_rows then
  return ('     ');
when others then
  return ('     ');
end GET_ITEM_NUMBER;
--
END ICX_MARGIN_WEB_ANA_PKG;

/
