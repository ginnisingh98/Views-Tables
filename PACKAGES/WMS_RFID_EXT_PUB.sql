--------------------------------------------------------
--  DDL for Package WMS_RFID_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RFID_EXT_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSRFEXS.pls 120.0 2005/05/24 18:31:29 appldev noship $ */

PROCEDURE get_new_load_verif_threshold(p_org_id IN NUMBER,
				       p_pallet_lpn_id IN NUMBER,
				       x_new_load_verif_threshold OUT nocopy NUMBER,
				       x_return_status OUT nocopy NUMBER);


END wms_rfid_ext_pub;

 

/
