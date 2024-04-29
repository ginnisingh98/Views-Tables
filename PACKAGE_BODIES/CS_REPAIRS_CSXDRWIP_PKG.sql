--------------------------------------------------------
--  DDL for Package Body CS_REPAIRS_CSXDRWIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_REPAIRS_CSXDRWIP_PKG" as
/* $Header: csdrwipb.pls 115.0 99/07/16 08:57:23 porting ship $ */

procedure lock_row
(
	p_rowid                  in out varchar2,
	p_repair_line_id                number,
	p_rma_number                    number,
	p_rma_cust_id                   number,
	p_rma_type_id                   number,
	p_rma_dt                        date,
	p_estimate_id                   number,
	p_diagnosis_id                  number,
	p_job_completion_date           date,
	p_wip_entity_id                 number,
	p_customer_product_id           number,
	p_inventory_item_id             number,
	p_serial_number                 varchar2,
	p_recvd_org_id                  number,
	p_quantity_received             number,
	p_repair_unit_of_measure_code   varchar2,
	p_status                        varchar2,
	p_group_id                      number
) is
	cursor c1 is
	select *
	from cs_repairs
	where rowid = p_rowid
	for update nowait;
	--
	--cursor c2 is
	--select job_completion_date,diagnosis_id
	--from cs_estimates
	--where repair_line_id = p_repair_line_id
	--for update nowait;
	--
	recinfo1 c1%rowtype;
	--recinfo2 c2%rowtype;
begin
	open c1;
	fetch c1 into recinfo1;
	if c1%notfound then
		close c1;
		fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
		app_exception.raise_exception;
	end if;
	close c1;

	--open c2;
	--fetch c2 into recinfo2;
	--if c2%notfound then
     --		close c2;
     --		fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
     --		app_exception.raise_exception;
     --	end if;
     --	close c2;

	if  (recinfo1.repair_line_id = p_repair_line_id)
	and ((recinfo1.rma_customer_id = p_rma_cust_id) or
		(recinfo1.rma_customer_id is null and p_rma_cust_id is null))
	and ((recinfo1.rma_number = p_rma_number) or
		(recinfo1.rma_number is null and p_rma_number is null))
	and ((recinfo1.rma_type_id = p_rma_type_id) or
		(recinfo1.rma_type_id is null and p_rma_type_id is null))
	and ((recinfo1.rma_date = p_rma_dt) or
		(recinfo1.rma_date is null and p_rma_dt is null))
	and ((recinfo1.estimate_id = p_estimate_id) or
		(recinfo1.estimate_id is null and p_estimate_id is null))
	and ((recinfo1.diagnosis_id = p_diagnosis_id) or
		(recinfo1.diagnosis_id is null and p_diagnosis_id is null))
	and ((recinfo1.job_completion_date = p_job_completion_date) or
		(recinfo1.job_completion_date is null and p_job_completion_date is null))
	and ((recinfo1.wip_entity_id = p_wip_entity_id) or
		(recinfo1.wip_entity_id is null and p_wip_entity_id is null))
	and ((recinfo1.group_id = p_group_id) or
		(recinfo1.group_id is null and p_group_id is null))
	and ((recinfo1.customer_product_id = p_customer_product_id) or
		(recinfo1.customer_product_id is null and p_customer_product_id is null))
	and (recinfo1.inventory_item_id = p_inventory_item_id)
	and ((recinfo1.serial_number = p_serial_number) or
		(recinfo1.serial_number is null and p_serial_number is null))
	and (recinfo1.recvd_organization_id = p_recvd_org_id)
	and (recinfo1.quantity_received = p_quantity_received)
	and ((recinfo1.repair_unit_of_measure_code = p_repair_unit_of_measure_code) or
		(recinfo1.repair_unit_of_measure_code is null and p_repair_unit_of_measure_code is null))
	and (recinfo1.status = p_status) then
		null;
	else
		fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
		app_exception.raise_exception;
	end if;
end lock_row;

procedure update_row
(
	p_rowid                         varchar2,
	p_last_update_date              date,
	p_last_updated_by               number,
	p_last_update_login             number,
	p_status                        varchar2,
	p_wip_entity_id                 number,
	p_group_id                      number
) is
begin
	update cs_repairs
	set
		status = p_status,
		wip_entity_id = p_wip_entity_id,
		group_id = p_group_id,
		last_update_date = p_last_update_date,
		last_updated_by = p_last_updated_by,
		last_update_login = p_last_update_login
	where rowid = p_rowid;
	--
	if sql%notfound then
		raise NO_DATA_FOUND;
	end if;
	--
	insert into cs_repair_history
	(
		repair_history_id,
		repair_line_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		status,
		transaction_date
	)
	select
		cs_repair_history_s.nextval,
		repair_line_id,
		last_update_date,
		last_updated_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		status,
		last_update_date
	from cs_repairs
	where rowid = p_rowid;
end update_row;

end cs_repairs_csxdrwip_pkg;

/
