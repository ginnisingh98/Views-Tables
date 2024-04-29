--------------------------------------------------------
--  DDL for Package CN_COLLECTION_AR_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECTION_AR_GEN" AUTHID CURRENT_USER AS
-- $Header: cnargens.pls 120.2 2005/08/29 08:14:13 vensrini noship $

  PROCEDURE insert_trx (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code		IN OUT NOCOPY	cn_utils.code_type,
	x_org_id IN NUMBER);

  PROCEDURE update_trx (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code		IN OUT NOCOPY	cn_utils.code_type,
	x_org_id IN NUMBER);

  PROCEDURE insert_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER);

  PROCEDURE update_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER);

  PROCEDURE insert_sales_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER);

  PROCEDURE update_sales_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER);

  PROCEDURE update_invoice_total (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER);

  PROCEDURE insert_comm_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER);

END cn_collection_ar_gen;

 

/
