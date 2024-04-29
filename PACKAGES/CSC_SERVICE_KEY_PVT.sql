--------------------------------------------------------
--  DDL for Package CSC_SERVICE_KEY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_SERVICE_KEY_PVT" AUTHID CURRENT_USER AS
/* $Header: cscvpsks.pls 120.2 2005/11/29 14:33:07 akalidin noship $ */

 -- This record type stores all the ID's that found when search is made on
 -- service key. It is used in defining table of records.
 TYPE hdr_info_rec_type IS RECORD (
	service_key_id	NUMBER,
 	cust_party_id   NUMBER,
	cust_phone_id   NUMBER,
	cust_email_id   NUMBER,
	rel_party_id    NUMBER,
	per_party_id    NUMBER,
	rel_phone_id    NUMBER,
	rel_email_id    NUMBER,
	org_id    NUMBER,
	Account_id      NUMBER,
	Employee_Id	NUMBER
 );

 -- This table of record stores all ID's when multiple records are found
 -- when search is made on service key.
 TYPE hdr_info_tbl_type IS TABLE OF hdr_info_rec_type INDEX BY BINARY_INTEGER;

 -- This procedure accepts service key name, service key value and returns all
 -- ID information that are found when search is made on a servcie key name and
 -- value.
 PROCEDURE Service_Key_Search (
				p_skey_name IN VARCHAR2,
				p_skey_value IN VARCHAR2,
				x_hdr_info_tbl OUT NOCOPY HDR_INFO_TBL_TYPE );

END CSC_SERVICE_KEY_PVT;

 

/
