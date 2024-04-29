--------------------------------------------------------
--  DDL for Package CS_REPAIRS_CSXDRWIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_REPAIRS_CSXDRWIP_PKG" AUTHID CURRENT_USER as
/* $Header: csdrwips.pls 115.0 99/07/16 08:57:26 porting ship $ */

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
);

procedure update_row
(
	p_rowid                         varchar2,
	p_last_update_date              date,
	p_last_updated_by               number,
	p_last_update_login             number,
	p_status                        varchar2,
	p_wip_entity_id                 number,
	p_group_id                      number
);

end cs_repairs_csxdrwip_pkg;

 

/
