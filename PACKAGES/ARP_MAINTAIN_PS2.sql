--------------------------------------------------------
--  DDL for Package ARP_MAINTAIN_PS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_MAINTAIN_PS2" AUTHID CURRENT_USER AS
/* $Header: ARTEMP2S.pls 120.4.12010000.1 2008/07/24 16:56:22 appldev ship $ */

--
-- Public cursors
--
ips_insert_ps_c		INTEGER;
ips_select_c		INTEGER;

ira_insert_ps_c		INTEGER;
ira_insert_ra_c		INTEGER;
ira_update_ps_c		INTEGER;
ira_select_c		INTEGER;

ups_insert_adj_c	INTEGER;
ups_update_ps_c		INTEGER;
ups_select_c		INTEGER;

iad_insert_adj_c	INTEGER;
iad_update_ps_c		INTEGER;
iad_select_c		INTEGER;


PROCEDURE insert_inv_ps_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 		IN BINARY_INTEGER,
	p_reversed_cash_receipt_id	IN BINARY_INTEGER );

PROCEDURE insert_cm_ps_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER );

PROCEDURE insert_child_adj_private(
	p_customer_trx_id 	IN BINARY_INTEGER,
        p_adj_date              IN DATE DEFAULT NULL,
        p_gl_date               IN DATE DEFAULT NULL);

PROCEDURE insert_child_adj_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER,
        p_adj_date              IN DATE DEFAULT NULL,
        p_gl_date               IN DATE DEFAULT NULL);

PROCEDURE insert_cm_child_adj_private(
	p_system_info		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER );

PROCEDURE test_build_ips_sql;
PROCEDURE test_build_ira_sql;
PROCEDURE test_build_ups_sql;
PROCEDURE test_build_iad_sql;
PROCEDURE test_insert_inv_ps(
	p_customer_trx_id BINARY_INTEGER,
	p_reversed_cash_receipt_id	IN BINARY_INTEGER );
PROCEDURE test_ai_insert_inv_ps(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 );
PROCEDURE test_insert_cm_ps( p_customer_trx_id BINARY_INTEGER );
PROCEDURE test_ai_insert_cm_ps(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 );
PROCEDURE test_insert_child_adj( p_customer_trx_id BINARY_INTEGER );
PROCEDURE test_ai_insert_child_adj(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 );
PROCEDURE test_insert_cm_child_adj( p_customer_trx_id BINARY_INTEGER );
PROCEDURE test_ai_insert_cm_child_adj(
		p_request_id BINARY_INTEGER,
		p_select_sql VARCHAR2 );

PROCEDURE init;

END arp_maintain_ps2;

/
