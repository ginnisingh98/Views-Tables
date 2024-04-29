--------------------------------------------------------
--  DDL for Package Body MTL_MOVEMENT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MOVEMENT_RPT_PKG" as
/* $Header: INVMVTPB.pls 115.3 99/07/16 10:59:14 porting ship  $ */
--
----------------------------------------
-- Exchange Rate Calculation Function --
----------------------------------------
function EXCHANGE_RATE_CALC
	(C_CONVERSION_OPTION    varchar2,
	 C_CONVERSION_TYPE      varchar2,
	 C_SET_OF_BOOKS_ID      number,
	 C_END_DATE             date,
         C_CURRENCY_CODE        varchar2,
	 l_currency_code        varchar2,
	 l_transaction_date     date,
         l_invoice_id           number,
         l_document_source_type varchar2,
         l_movement_type        varchar2)
return number
is
--
l_exchange_rate number;
--
begin
-- If movement currency code is the same
-- as the functionnal currency code
if l_currency_code = C_CURRENCY_CODE
  then
  l_exchange_rate := 1;
else
  -- If there is no invoice_id
  if l_invoice_id is null
    then
    -- If CONVERSION_OPTION is Daily
    if C_CONVERSION_OPTION = 'D'
      then
      begin
	l_exchange_rate := gl_currency_api.get_rate(
					c_set_of_books_id,
					l_currency_code,
					l_transaction_date,
					c_conversion_type);

	exception when gl_currency_api.no_rate then
          l_exchange_rate := null;
      end;
    -- If CONVERSION_OPTION is Last day of the period
    elsif C_CONVERSION_OPTION = 'L'
      then
      begin
	l_exchange_rate := gl_currency_api.get_rate(
					c_set_of_books_id,
					l_currency_code,
					c_end_date,
					c_conversion_type);

      exception when gl_currency_api.no_rate then
        l_exchange_rate := null;
      end;
    else l_exchange_rate := null;
    end if;
  -- If DOCUMENT_SOURCE_TYPE is Purchase Order
  -- or (DOCUMENT_SOURCE_TYPE is Inventory
  -- and MOVEMENT_TYPE is Arrival or Arrival Adjustment)
  elsif l_document_source_type = 'PO'
        or (l_document_source_type = 'INV'
            and l_movement_type in ('A','AA'))
    then
    begin
    select exchange_rate into l_exchange_rate
    from ap_invoices
    where invoice_id = l_invoice_id;
    exception when no_data_found
    then l_exchange_rate := null;
    end;
  -- If DOCUMENT_SOURCE_TYPE is Sales Order
  -- or DOCUMENT_SOURCE_TYPE is Return Merchandise Adjustment
  -- or (DOCUMENT_SOURCE_TYPE is Inventory
  -- and MOVEMENT_TYPE is Dispatch or Dispatch Adjustment)
  elsif l_document_source_type = 'SO'
        or l_document_source_type = 'RMA'
        or (l_document_source_type = 'INV'
            and l_movement_type in ('D','DA'))
    then
    begin
    select exchange_rate into l_exchange_rate
    from ra_customer_trx
    where customer_trx_id = l_invoice_id;
    exception when no_data_found
    then l_exchange_rate := null;
    end;
  else l_exchange_rate := null;
  end if;
end if;
return(l_exchange_rate);
--
end EXCHANGE_RATE_CALC;
--
-----------------------------------------------------------------------------
------------------------------------------
-- Conversion Date Calculation Function --
------------------------------------------
function CONVERSION_DATE_CALC
	(C_END_DATE		date,
	 C_CONVERSION_OPTION	varchar2,
         C_CURRENCY_CODE        varchar2,
         l_currency_code        varchar2,
	 l_transaction_date	date,
         l_invoice_id           number,
         l_document_source_type varchar2,
         l_movement_type        varchar2)
return date
is
--
l_exchange_date date;
--
begin
-- If movement currency code is the same
-- as the functionnal currency code
if l_currency_code = C_CURRENCY_CODE
  then
  l_exchange_date := null;
else
  -- If there is no invoice_id
  if l_invoice_id is null
    then
    -- If CONVERSION_OPTION is Daily
    if C_CONVERSION_OPTION = 'D'
      then  l_exchange_date := l_transaction_date;
    -- If CONVERSION_OPTION is Last day of the period
    elsif C_CONVERSION_OPTION = 'L'
      then l_exchange_date := C_END_DATE;
    else l_exchange_date := null;
    end if;
  -- If DOCUMENT_SOURCE_TYPE is Purchase Order
  -- or (DOCUMENT_SOURCE_TYPE is Inventory
  -- and MOVEMENT_TYPE is Arrival or Arrival Adjustment)
  elsif l_document_source_type = 'PO'
        or (l_document_source_type = 'INV'
            and l_movement_type in ('A','AA'))
    then
    begin
    select exchange_date into l_exchange_date
    from ap_invoices
    where invoice_id = l_invoice_id;
    exception when no_data_found
    then l_exchange_date := null;
    end;
  -- If DOCUMENT_SOURCE_TYPE is Sales Order
  -- or DOCUMENT_SOURCE_TYPE is Return Merchandise Adjustment
  -- or (DOCUMENT_SOURCE_TYPE is Inventory
  -- and MOVEMENT_TYPE is Dispatch or Dispatch Adjustment)
  elsif l_document_source_type = 'SO'
        or l_document_source_type = 'RMA'
        or (l_document_source_type = 'INV'
            and l_movement_type in ('D','DA'))
    then
    begin
    select exchange_date into l_exchange_date
    from ra_customer_trx
    where customer_trx_id = l_invoice_id;
    exception when no_data_found
    then l_exchange_date := null;
    end;
  else l_exchange_date := null;
  end if;
end if;
return(l_exchange_date);
--
end CONVERSION_DATE_CALC;
--
-----------------------------------------------------------------------------
--------------------------------------
-- Unit Weight Calculation Function --
--------------------------------------
function UNIT_WEIGHT_CALC
	(l_inventory_item_id	number,
	 l_organization_id	number,
	 P_LEGAL_ENTITY_ID	number)
return number
is
--
l_conversion_rate number;
--
begin
if l_inventory_item_id is not null
  then
  begin
  select
  conversion_rate into l_conversion_rate
  from
  mtl_uom_conversions_view muc,
  mtl_movement_parameters mmp
  where
  muc.inventory_item_id = l_inventory_item_id
  and muc.organization_id = l_organization_id
  and muc.uom_code = mmp.weight_uom_code
  and mmp.entity_org_id = P_LEGAL_ENTITY_ID;
  exception when no_data_found
  then l_conversion_rate := null;
  end;
else l_conversion_rate := null;
end if;
return (l_conversion_rate);
--
end UNIT_WEIGHT_CALC;
--
-----------------------------------------------------------------------------
---------------------------------
-- Weight Calculation Function --
---------------------------------
function WEIGHT_CALC
	(l_total_weight		number,
	 l_inventory_item_id	number,
	 l_organization_id	number,
	 l_transaction_quantity number,
	 l_transaction_uom_code	varchar2,
	 P_LEGAL_ENTITY_ID	number,
         P_FORMAT_TYPE          varchar2)
return number
is
--
l_conversion_rate number;
l_weight          number;
--
begin
----------------------------------------------
-- Conversion from movement unit of measure --
-- to the base unit                         --
----------------------------------------------
begin
select
conversion_rate into l_conversion_rate
from
mtl_uom_conversions_view
where
inventory_item_id = l_inventory_item_id
and organization_id = l_organization_id
and uom_code = l_transaction_uom_code;
exception when no_data_found
then l_conversion_rate := 1;
end;
l_weight := l_transaction_quantity * l_conversion_rate;
--
------------------------------------------
-- Conversion from base unit of measure --
-- to legal_entity unit                 --
------------------------------------------
begin
select
conversion_rate into l_conversion_rate
from
mtl_uom_conversions_view muc,
mtl_movement_parameters mmp
where
muc.inventory_item_id = l_inventory_item_id
and muc.organization_id = l_organization_id
and muc.uom_code = mmp.weight_uom_code
and mmp.entity_org_id = P_LEGAL_ENTITY_ID;
exception when no_data_found
then l_conversion_rate := 1;
end;
l_weight := l_weight / l_conversion_rate;
--
-- Weight rounded up for all the EEC countries
-- except Portugal who need 3 decimals
if P_FORMAT_TYPE = 'PT'
  then l_weight := round(l_weight,3);
else l_weight := ceil(l_weight);
end if;
--
return(l_weight);
--
end WEIGHT_CALC;
--
-----------------------------------------------------------------------------
--------------------------------------
-- Date Report Calculation Function --
--------------------------------------
function REPORT_DATE_CALC
	(l_invoice_date_reference	date,
	 l_transaction_date		date)
return date
is
--
l_report_date date;
--
begin
if l_invoice_date_reference is not null
  then
  if l_invoice_date_reference
    between l_transaction_date and add_months(l_transaction_date,1)
    then l_report_date := l_invoice_date_reference;
  else l_report_date := l_transaction_date;
  end if;
 else l_report_date :=
   To_date(To_char(Add_months(l_transaction_date, 1), 'YYYY/MM')
	   || '/15', 'YYYY/MM/DD');
end if;
return(l_report_date);
--
end REPORT_DATE_CALC;
--
-----------------------------------------------------------------------------
------------------------------------------
-- Update mtl_movement_statistics table --
-- executed in Before Report Trigger    --
------------------------------------------
--
procedure BEFORE_REPORT_UPDATES
	(P_USER_ID		in number,
	 P_CONC_LOGIN_ID	in number,
	 P_PERIOD_NAME		in varchar2,
	 P_CONC_REQUEST_ID	in number,
	 P_CONC_APPLICATION_ID	in number,
	 P_CONC_PROGRAM_ID	in number,
	 P_REPORT_OPTION	in varchar2,
	 P_MOVEMENT_TYPE	in varchar2,
	 P_LEGAL_ENTITY_ID	in number,
	 P_REPORT_REFERENCE	in number,
         P_FORMAT_TYPE          in varchar2,
	 C_CONVERSION_TYPE	in varchar2,
	 C_CONVERSION_OPTION	in varchar2,
	 C_SET_OF_BOOKS_ID	in number,
	 C_START_DATE		in date,
	 C_END_DATE		in date,
         C_CURRENCY_CODE        in varchar2)
is
--
begin
--
------------------------------------------------------
-- if REPORT OPTION is not Nullify Official/Summary --
------------------------------------------------------
if P_REPORT_OPTION <> 'NO/S'
  then
  begin
  -------------------------------------------------------
  -- Update of INVOICE_DATE_REFERENCE                  --
  -- in MTL_MOVEMENT_STATISTICS table                  --
  -- if DOCUMENT_SOURCE_TYPE is not Miscellaneous      --
  -- (Required for Where Clause of select and updates) --
  -------------------------------------------------------
  update mtl_movement_statistics mms
  set invoice_date_reference = (select invoice_date
                               from ap_invoices
                               where invoice_id = mms.invoice_id)
  where mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and mms.movement_status = 'O'
  and mms.document_source_type = 'PO'
  and mms.invoice_id is not null;
  --
  update mtl_movement_statistics mms
  set invoice_date_reference = (select trx_date
                               from ra_customer_trx
                               where customer_trx_id = mms.invoice_id)
  where mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and mms.movement_status = 'O'
  and mms.document_source_type = 'SO'
  and mms.invoice_id is not null;
  --
  ---------------------------------------------
  -- Update in MTL_MOVEMENT_STATISTICS table --
  -- for the movements of the period         --
  ---------------------------------------------
  update mtl_movement_statistics mms
  set
  last_update_date = sysdate,
  last_updated_by = P_USER_ID,
  last_update_login = P_CONC_LOGIN_ID,
  period_name = P_PERIOD_NAME,
  report_reference = P_REPORT_REFERENCE,
  report_date = MTL_MOVEMENT_RPT_PKG.REPORT_DATE_CALC
		(invoice_date_reference,
		 transaction_date)
  where
  mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and ((decode(P_MOVEMENT_TYPE,
               'D', mms.destination_territory_code,
               'DA', mms.destination_territory_code,
               'A', mms.dispatch_territory_code,
               'AA', mms.dispatch_territory_code)
               in (select territory_code from fnd_territories_vl)
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.dispatch_territory_code,
                    'DA', mms.dispatch_territory_code,
                    'A', mms.destination_territory_code,
                    'AA', mms.destination_territory_code) = P_FORMAT_TYPE
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.destination_territory_code,
                    'DA', mms.destination_territory_code,
                    'A', mms.dispatch_territory_code,
                    'AA', mms.dispatch_territory_code) <> P_FORMAT_TYPE)
         or P_FORMAT_TYPE = 'GEN')
  and (mms.movement_type in ('AA','DA')
       or
      (mms.movement_type not in ('AA','DA')
       and ((mms.invoice_id is null and mms.invoice_reference is null
             and add_months(mms.transaction_date,1)
                 between C_START_DATE and C_END_DATE)
             or
           ((mms.invoice_id is not null or mms.invoice_reference is not null)
             and (mms.invoice_date_reference
                  between transaction_date
                          and add_months(mms.transaction_date,1)
                  or
                  mms.transaction_date between C_START_DATE and C_END_DATE)))))
  and mms.movement_status = 'O';
  --
  -- Currency Conversion
  update mtl_movement_statistics mms
  set
  currency_conversion_rate = MTL_MOVEMENT_RPT_PKG.EXCHANGE_RATE_CALC
				(C_CONVERSION_OPTION,
				 C_CONVERSION_TYPE,
				 C_SET_OF_BOOKS_ID,
				 C_END_DATE,
                                 C_CURRENCY_CODE,
				 currency_code,
				 transaction_date,
                                 invoice_id,
                                 document_source_type,
                                 movement_type),
  currency_conversion_type = C_CONVERSION_TYPE,
  currency_conversion_date = MTL_MOVEMENT_RPT_PKG.CONVERSION_DATE_CALC
				(C_END_DATE,
				 C_CONVERSION_OPTION,
                                 C_CURRENCY_CODE,
                                 currency_code,
                                 transaction_date,
                                 invoice_id,
                                 document_source_type,
                                 movement_type)
  where
  mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and ((decode(P_MOVEMENT_TYPE,
               'D', mms.destination_territory_code,
               'DA', mms.destination_territory_code,
               'A', mms.dispatch_territory_code,
               'AA', mms.dispatch_territory_code)
               in (select territory_code from fnd_territories_vl)
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.dispatch_territory_code,
                    'DA', mms.dispatch_territory_code,
                    'A', mms.destination_territory_code,
                    'AA', mms.destination_territory_code) = P_FORMAT_TYPE
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.destination_territory_code,
                    'DA', mms.destination_territory_code,
                    'A', mms.dispatch_territory_code,
                    'AA', mms.dispatch_territory_code) <> P_FORMAT_TYPE)
         or P_FORMAT_TYPE = 'GEN')
  and (mms.movement_type in ('AA','DA')
       or
      (mms.movement_type not in ('AA','DA')
       and ((mms.invoice_id is null and mms.invoice_reference is null
             and add_months(mms.transaction_date,1)
                 between C_START_DATE and C_END_DATE)
             or
           ((mms.invoice_id is not null or mms.invoice_reference is not null)
             and (mms.invoice_date_reference
                  between transaction_date
                          and add_months(mms.transaction_date,1)
                  or
                  mms.transaction_date between C_START_DATE and C_END_DATE)))))
  and mms.movement_status = 'O';
  --
  -- If WEIGHT_METHOD is System
  update mtl_movement_statistics mms
  set
  unit_weight = MTL_MOVEMENT_RPT_PKG.UNIT_WEIGHT_CALC
		(inventory_item_id,
		 organization_id,
		 P_LEGAL_ENTITY_ID),
  total_weight = MTL_MOVEMENT_RPT_PKG.WEIGHT_CALC
		(total_weight,
		 inventory_item_id,
		 organization_id,
		 transaction_quantity,
		 transaction_uom_code,
		 P_LEGAL_ENTITY_ID,
                 P_FORMAT_TYPE)
  where
  mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and ((decode(P_MOVEMENT_TYPE,
               'D', mms.destination_territory_code,
               'DA', mms.destination_territory_code,
               'A', mms.dispatch_territory_code,
               'AA', mms.dispatch_territory_code)
               in (select territory_code from fnd_territories_vl)
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.dispatch_territory_code,
                    'DA', mms.dispatch_territory_code,
                    'A', mms.destination_territory_code,
                    'AA', mms.destination_territory_code) = P_FORMAT_TYPE
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.destination_territory_code,
                    'DA', mms.destination_territory_code,
                    'A', mms.dispatch_territory_code,
                    'AA', mms.dispatch_territory_code) <> P_FORMAT_TYPE)
         or P_FORMAT_TYPE = 'GEN')
  and (mms.movement_type in ('AA','DA')
       or
      (mms.movement_type not in ('AA','DA')
       and ((mms.invoice_id is null and mms.invoice_reference is null
             and add_months(mms.transaction_date,1)
                 between C_START_DATE and C_END_DATE)
             or
           ((mms.invoice_id is not null or mms.invoice_reference is not null)
             and (mms.invoice_date_reference
                  between transaction_date
                          and add_months(mms.transaction_date,1)
                  or
                  mms.transaction_date between C_START_DATE and C_END_DATE)))))
  and mms.movement_status = 'O'
  and weight_method = 'S';
  end;
end if;
--
end BEFORE_REPORT_UPDATES;
--
-----------------------------------------------------------------------------
------------------------------------------
-- Update mtl_movement_statistics table --
-- and mtl_movement_parameters table    --
-- executed in After Report Trigger     --
------------------------------------------
--
procedure AFTER_REPORT_UPDATES
	(P_USER_ID               in number,
	 P_CONC_LOGIN_ID         in number,
	 P_PERIOD_NAME           in varchar2,
	 P_REPORT_OPTION		in varchar2,
	 P_MOVEMENT_TYPE         in varchar,
	 P_LEGAL_ENTITY_ID       in number,
	 P_REPORT_REFERENCE      in number,
         P_FORMAT_TYPE           in varchar2,
	 C_START_DATE            in date,
	 C_END_DATE              in date)
is
begin
--
------------------------------------------
-- if REPORT OPTION is Official/Summary --
--------------------------------------------
if P_REPORT_OPTION = 'O/S'
  then
  begin
  ------------------------------------------
  -- Update mtl_movement_parameters table --
  ------------------------------------------
  update mtl_movement_parameters
  set
  last_update_date = sysdate,
  last_updated_by = P_USER_ID,
  last_update_login = P_CONC_LOGIN_ID
  where entity_org_id = P_LEGAL_ENTITY_ID;
  --
  -- If MOVEMENT_TYPE is Arrival
  if P_MOVEMENT_TYPE = 'A'
    then
    update mtl_movement_parameters
    set
    last_arrival_id = P_REPORT_REFERENCE,
    last_arrival_period = P_PERIOD_NAME
    where entity_org_id = P_LEGAL_ENTITY_ID;
  end if;
  --
  -- If MOVEMENT_TYPE is Arrival Adjustment
  if P_MOVEMENT_TYPE = 'AA'
    then
    update mtl_movement_parameters
    set
    last_arrival_adj_id = P_REPORT_REFERENCE,
    last_arrival_adj_period = P_PERIOD_NAME
    where entity_org_id = P_LEGAL_ENTITY_ID;
  end if;
  --
  -- If MOVEMENT_TYPE is Dispatch
  if P_MOVEMENT_TYPE = 'D'
    then
    update mtl_movement_parameters
    set
    last_dispatch_id = P_REPORT_REFERENCE,
    last_dispatch_period = P_PERIOD_NAME
    where entity_org_id = P_LEGAL_ENTITY_ID;
  end if;
  --
  -- If MOVEMENT_TYPE is Dispatch Adjustment
  if P_MOVEMENT_TYPE = 'DA'
    then
    update mtl_movement_parameters
    set
    last_dispatch_adj_id = P_REPORT_REFERENCE,
    last_dispatch_adj_period = P_PERIOD_NAME
    where entity_org_id = P_LEGAL_ENTITY_ID;
  end if;
  --
  ------------------------------------------
  -- Update mtl_movement_statistics table --
  -- for Freeze                           --
  ------------------------------------------
  update mtl_movement_statistics mms
  set
  movement_status = 'F'
  where
  mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and ((decode(P_MOVEMENT_TYPE,
               'D', mms.destination_territory_code,
               'DA', mms.destination_territory_code,
               'A', mms.dispatch_territory_code,
               'AA', mms.dispatch_territory_code)
               in (select territory_code from fnd_territories_vl)
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.dispatch_territory_code,
                    'DA', mms.dispatch_territory_code,
                    'A', mms.destination_territory_code,
                    'AA', mms.destination_territory_code) = P_FORMAT_TYPE
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.destination_territory_code,
                    'DA', mms.destination_territory_code,
                    'A', mms.dispatch_territory_code,
                    'AA', mms.dispatch_territory_code) <> P_FORMAT_TYPE)
         or P_FORMAT_TYPE = 'GEN')
  and (mms.movement_type in ('AA','DA')
       or
      (mms.movement_type not in ('AA','DA')
       and ((mms.invoice_id is null and mms.invoice_reference is null
             and add_months(mms.transaction_date,1)
                 between C_START_DATE and C_END_DATE)
             or
           ((mms.invoice_id is not null or mms.invoice_reference is not null)
             and (mms.invoice_date_reference
                  between transaction_date
                          and add_months(mms.transaction_date,1)
                  or
                  mms.transaction_date between C_START_DATE and C_END_DATE)))))
  and mms.movement_status = 'O';
  end;
end if;
--
--------------------------------------------------
-- if REPORT OPTION is Nullify Official/Summary --
--------------------------------------------------
if P_REPORT_OPTION = 'NO/S'
  then
  begin
  ------------------------------------------
  -- Update mtl_movement_statistics table --
  -- for Open                             --
  ------------------------------------------
  update mtl_movement_statistics mms
  set
  movement_status = 'O',
  last_update_date = sysdate,
  last_updated_by = P_USER_ID,
  last_update_login = P_CONC_LOGIN_ID,
  period_name = null,
  report_reference = null,
  report_date = null
  where
  mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and ((decode(P_MOVEMENT_TYPE,
               'D', mms.destination_territory_code,
               'DA', mms.destination_territory_code,
               'A', mms.dispatch_territory_code,
               'AA', mms.dispatch_territory_code)
               in (select territory_code from fnd_territories_vl)
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.dispatch_territory_code,
                    'DA', mms.dispatch_territory_code,
                    'A', mms.destination_territory_code,
                    'AA', mms.destination_territory_code) = P_FORMAT_TYPE
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.destination_territory_code,
                    'DA', mms.destination_territory_code,
                    'A', mms.dispatch_territory_code,
                    'AA', mms.dispatch_territory_code) <> P_FORMAT_TYPE)
         or P_FORMAT_TYPE = 'GEN')
  and (mms.movement_type in ('AA','DA')
       or
      (mms.movement_type not in ('AA','DA')
       and ((mms.invoice_id is null and mms.invoice_reference is null
             and add_months(mms.transaction_date,1)
                 between C_START_DATE and C_END_DATE)
             or
           ((mms.invoice_id is not null or mms.invoice_reference is not null)
             and (mms.invoice_date_reference
                  between transaction_date
                          and add_months(mms.transaction_date,1)
                  or
                  mms.transaction_date between C_START_DATE and C_END_DATE)))))
  and mms.movement_status = 'F';
  --
  -- If DOCUMENT_SOURCE_TYPE is Miscelaneous
  update mtl_movement_statistics mms
  set
  currency_conversion_rate = null,
  currency_conversion_type = null,
  currency_conversion_date = null
  where
  mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and ((decode(P_MOVEMENT_TYPE,
               'D', mms.destination_territory_code,
               'DA', mms.destination_territory_code,
               'A', mms.dispatch_territory_code,
               'AA', mms.dispatch_territory_code)
               in (select territory_code from fnd_territories_vl)
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.dispatch_territory_code,
                    'DA', mms.dispatch_territory_code,
                    'A', mms.destination_territory_code,
                    'AA', mms.destination_territory_code) = P_FORMAT_TYPE
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.destination_territory_code,
                    'DA', mms.destination_territory_code,
                    'A', mms.dispatch_territory_code,
                    'AA', mms.dispatch_territory_code) <> P_FORMAT_TYPE)
         or P_FORMAT_TYPE = 'GEN')
  and (mms.movement_type in ('AA','DA')
       or
      (mms.movement_type not in ('AA','DA')
       and ((mms.invoice_id is null and mms.invoice_reference is null
             and add_months(mms.transaction_date,1)
                 between C_START_DATE and C_END_DATE)
             or
           ((mms.invoice_id is not null or mms.invoice_reference is not null)
             and (mms.invoice_date_reference
                  between transaction_date
                          and add_months(mms.transaction_date,1)
                  or
                  mms.transaction_date between C_START_DATE and C_END_DATE)))))
  and mms.movement_status = 'F'
  and mms.document_source_type <> 'MISC';
  --
  -- If WEIGHT_METHOD is not Manual
  update mtl_movement_statistics mms
  set
  unit_weight = null,
  total_weight = null
  where
  mms.movement_type = P_MOVEMENT_TYPE
  and mms.entity_org_id = P_LEGAL_ENTITY_ID
  and ((decode(P_MOVEMENT_TYPE,
               'D', mms.destination_territory_code,
               'DA', mms.destination_territory_code,
               'A', mms.dispatch_territory_code,
               'AA', mms.dispatch_territory_code)
               in (select territory_code from fnd_territories_vl)
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.dispatch_territory_code,
                    'DA', mms.dispatch_territory_code,
                    'A', mms.destination_territory_code,
                    'AA', mms.destination_territory_code) = P_FORMAT_TYPE
         and decode(P_MOVEMENT_TYPE,
                    'D',mms.destination_territory_code,
                    'DA', mms.destination_territory_code,
                    'A', mms.dispatch_territory_code,
                    'AA', mms.dispatch_territory_code) <> P_FORMAT_TYPE)
         or P_FORMAT_TYPE = 'GEN')
  and (mms.movement_type in ('AA','DA')
       or
      (mms.movement_type not in ('AA','DA')
       and ((mms.invoice_id is null and mms.invoice_reference is null
             and add_months(mms.transaction_date,1)
                 between C_START_DATE and C_END_DATE)
             or
           ((mms.invoice_id is not null or mms.invoice_reference is not null)
             and (mms.invoice_date_reference
                  between transaction_date
                          and add_months(mms.transaction_date,1)
                  or
                  mms.transaction_date between C_START_DATE and C_END_DATE)))))
  and mms.movement_status = 'F'
  and mms.weight_method <> 'M';
  end;
end if;
--
end AFTER_REPORT_UPDATES;
--
-----------------------------------------------------------------------------
--
end MTL_MOVEMENT_RPT_PKG;

/
