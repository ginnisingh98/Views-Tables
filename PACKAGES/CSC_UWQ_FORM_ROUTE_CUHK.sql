--------------------------------------------------------
--  DDL for Package CSC_UWQ_FORM_ROUTE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_UWQ_FORM_ROUTE_CUHK" AUTHID CURRENT_USER AS
/* $Header: csctuhks.pls 115.0 2003/09/12 01:24:04 vxsriniv noship $ */

-- This procedure accepts media data object passed from UWQ and
-- returns a party id, account id, phone id or a combination of these.

-- PARAMETERS:
   -----------
-- p_ieu_media_data    { Media Data is passed in this parameter }
-- x_party_id          { Party ID is returned in this parameter }
-- x_cust_account_id   { Account ID is returned in this parameter }
-- x_phone_id          { Phone ID is returned in this parameter }

PROCEDURE CSC_UWQ_FORM_OBJ_PRE (
				p_ieu_media_data IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				x_party_id OUT NOCOPY NUMBER,
				x_cust_account_id OUT NOCOPY NUMBER,
				x_phone_id OUT NOCOPY NUMBER);

END CSC_UWQ_FORM_ROUTE_CUHK;

 

/
