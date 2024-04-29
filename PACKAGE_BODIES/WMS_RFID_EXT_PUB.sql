--------------------------------------------------------
--  DDL for Package Body WMS_RFID_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RFID_EXT_PUB" AS
--/* $Header: WMSRFEXB.pls 120.0 2005/05/25 09:06:19 appldev noship $ */
PROCEDURE get_new_load_verif_threshold(p_org_id IN NUMBER,
					    p_pallet_lpn_id IN NUMBER,
					    x_new_load_verif_threshold OUT nocopy NUMBER,
					    x_return_status OUT nocopy  NUMBER)
  AS


BEGIN
   x_return_status := 'S';
   x_new_load_verif_threshold := NULL;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'E';
      x_new_load_verif_threshold := NULL;

END get_new_load_verif_threshold;


END wms_rfid_ext_pub;

/
