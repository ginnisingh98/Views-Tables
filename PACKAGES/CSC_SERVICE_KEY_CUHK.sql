--------------------------------------------------------
--  DDL for Package CSC_SERVICE_KEY_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_SERVICE_KEY_CUHK" AUTHID CURRENT_USER AS
/* $Header: cscppsks.pls 115.3 2003/08/18 05:41:32 akalidin noship $ */

 -- This procedure accepts service key name, service key value and returns all
 -- ID information that are found when search is made on a servcie key name and
 -- value.
 -- PARAMTERS:
    ----------
 -- p_skey_name    { Service Key Name is passed to this parameter }
 -- p_skey_value   { Service Key Value is passed to this parameter }
 -- x_hdr_info_tbl { is Table of records. The record has the following columns }
 --                  { 1) cust_party_id NUMBER,
 --                    2) cust_phone_id NUMBER,
 --                    3) cust_email_id NUMBER,
 --                    4) rel_party_id  NUMBER,
 --                    5) per_party_id  NUMBER,
 --                    6) rel_phone_id  NUMBER,
 --                    7) rel_email_id  NUMBER,
 --                    8) Account_id    NUMBER }

 PROCEDURE Service_Key_Search_Pre (
				p_skey_name IN VARCHAR2,
				p_skey_value IN VARCHAR2,
				x_hdr_info_tbl OUT NOCOPY CSC_SERVICE_KEY_PVT.hdr_info_tbl_type );

END CSC_SERVICE_KEY_CUHK;

 

/
