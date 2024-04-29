--------------------------------------------------------
--  DDL for Package Body ONT_PRT_MARGIN_ANA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_PRT_MARGIN_ANA_PKG" as
/* $Header: ONTCSMAB.pls 120.0 2005/06/01 01:59:00 appldev noship $ */
procedure BUILD_ONT_PRT_MARGIN_TABLE AS
records_processed number;
sum_margin cst_margin_summary.margin%TYPE;
CURSOR wkly_amt_cursor IS
SELECT
	cms.build_id,
	cms.customer_id,
	cms.primary_salesrep_id,
	cms.territory_id,
	cms.inventory_item_id,
	cms.org_id,
	cms.sold_to_customer_name,
	sum(invoiced_amount) sum_inv_amt,
	sum(cogs_amount) sum_cogs_amt
FROM
	CST_MARGIN_SUMMARY cms,
	CST_MARGIN_BUILD cmb
WHERE
	cms.build_id = cmb.build_id AND
	cms.gl_date >= cmb.to_date - 7 AND
	cms.build_id = (select max(build_id) from cst_margin_summary)
GROUP BY
	cms.build_id,
	cms.customer_id,
	cms.primary_salesrep_id,
	cms.territory_id,
	cms.inventory_item_id,
	cms.org_id,
	cms.sold_to_customer_name
;

CURSOR mnthly_amt_cursor IS
SELECT
	cms.build_id,
	cms.customer_id,
	cms.primary_salesrep_id,
	cms.territory_id,
	cms.inventory_item_id,
	cms.org_id,
	cms.sold_to_customer_name,
	sum(invoiced_amount) sum_inv_amt,
	sum(cogs_amount) sum_cogs_amt
FROM
	CST_MARGIN_SUMMARY cms,
	CST_MARGIN_BUILD cmb
WHERE
	cms.build_id = cmb.build_id AND
	cms.gl_date >= cmb.to_date - 30 AND
	cms.build_id = (select max(build_id) from cst_margin_summary)
GROUP BY
	cms.build_id,
	cms.customer_id,
	cms.primary_salesrep_id,
	cms.territory_id,
	cms.inventory_item_id,
	cms.org_id,
	cms.sold_to_customer_name
;

CURSOR qrtrly_amt_cursor IS
SELECT
	cms.build_id,
	cms.customer_id,
	cms.primary_salesrep_id,
	cms.territory_id,
	cms.inventory_item_id,
	cms.org_id,
	cms.sold_to_customer_name,
	sum(invoiced_amount) sum_inv_amt,
	sum(cogs_amount) sum_cogs_amt
FROM
	CST_MARGIN_SUMMARY cms,
	CST_MARGIN_BUILD cmb
WHERE
	cms.build_id = cmb.build_id AND
	cms.gl_date >= cmb.to_date - 90 AND
	cms.build_id = (select max(build_id) from cst_margin_summary)
GROUP BY
	cms.build_id,
	cms.customer_id,
	cms.primary_salesrep_id,
	cms.territory_id,
	cms.inventory_item_id,
	cms.org_id,
	cms.sold_to_customer_name
;
--
BEGIN

--
/*   delete old data from tables   */
DELETE FROM ONT_PRT_MARGIN_ANALYSIS;
DELETE FROM ONT_PRT_MARGIN_ANA_ERR;

records_processed := 0;
FOR wkly_amt_rec IN wkly_amt_cursor LOOP
--
  declare
  tmp_build_id CST_MARGIN_SUMMARY.build_id%TYPE;
  tmp_customer_id CST_MARGIN_SUMMARY.customer_id%TYPE;
  tmp_pri_salesrep_id CST_MARGIN_SUMMARY.primary_salesrep_id%TYPE;
  tmp_territory_id CST_MARGIN_SUMMARY.territory_id%TYPE;
  tmp_inv_item_id CST_MARGIN_SUMMARY.inventory_item_id%TYPE;
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

  INSERT INTO ONT_PRT_MARGIN_ANALYSIS
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
        INSERT into ONT_PRT_MARGIN_ANA_ERR
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
        INSERT into ONT_PRT_MARGIN_ANA_ERR
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
  tmp_build_id CST_MARGIN_SUMMARY.build_id%TYPE;
  tmp_customer_id CST_MARGIN_SUMMARY.customer_id%TYPE;
  tmp_pri_salesrep_id CST_MARGIN_SUMMARY.primary_salesrep_id%TYPE;
  tmp_territory_id CST_MARGIN_SUMMARY.territory_id%TYPE;
  tmp_inv_item_id CST_MARGIN_SUMMARY.inventory_item_id%TYPE;
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

  INSERT INTO ONT_PRT_MARGIN_ANALYSIS
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
        INSERT into ONT_PRT_MARGIN_ANA_ERR
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
        INSERT into ONT_PRT_MARGIN_ANA_ERR
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
  tmp_build_id CST_MARGIN_SUMMARY.build_id%TYPE;
  tmp_customer_id CST_MARGIN_SUMMARY.customer_id%TYPE;
  tmp_pri_salesrep_id CST_MARGIN_SUMMARY.primary_salesrep_id%TYPE;
  tmp_territory_id CST_MARGIN_SUMMARY.territory_id%TYPE;
  tmp_inv_item_id CST_MARGIN_SUMMARY.inventory_item_id%TYPE;
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

  INSERT INTO ONT_PRT_MARGIN_ANALYSIS
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
        INSERT into ONT_PRT_MARGIN_ANA_ERR
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
        INSERT into ONT_PRT_MARGIN_ANA_ERR
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

end BUILD_ONT_PRT_MARGIN_TABLE;


--	GET_TOTAL_SALES ==> returns the sum of the invoiced_amounts from the
--					CST_MARGIN_SUMMARY table based on the period passed in
--
function get_total_sales (in_period in varchar2) return number as
  tot_inv_amount number;
begin
select sum(invoiced_amount)
  into tot_inv_amount
  from ONT_PRT_MARGIN_ANALYSIS
  where period=in_period;
return (tot_inv_amount);
end get_total_sales;
--

--		GET_TOTAL_MARGIN ==>returns the sum of the margins from the
--					CST_MARGIN_SUMMARY table based on the period passed in
--
function get_total_margin (in_period in varchar2) return number as
 tot_margin_amount number;
begin
select sum(margin)
  into tot_margin_amount
  from ONT_PRT_MARGIN_ANALYSIS
  where period=in_period;
return  tot_margin_amount;
end get_total_margin;
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
END ONT_PRT_MARGIN_ANA_PKG;

/
