--------------------------------------------------------
--  DDL for Package ARP_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TMP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTMPS.pls 120.0 2005/12/23 02:32:21 hyu noship $ */


PROCEDURE workaround_remit_loc_api
( p_location_id     IN NUMBER    DEFAULT NULL,
  p_country         IN VARCHAR2  DEFAULT NULL,
  p_ADDRESS1        IN VARCHAR2  DEFAULT NULL,
  p_CITY            IN VARCHAR2  DEFAULT NULL,
  p_POSTAL_CODE     IN VARCHAR2  DEFAULT NULL,
  p_STATE           IN VARCHAR2  DEFAULT NULL,
  p_PROVINCE        IN VARCHAR2  DEFAULT NULL,
  p_COUNTY          IN VARCHAR2  DEFAULT NULL,
  p_org_id          IN NUMBER,
  x_cust_acct_site_id OUT NOCOPY NUMBER,
  x_party_site_id     OUT NOCOPY NUMBER,
  x_return_status   OUT NOCOPY   VARCHAR2,
  x_msg_data        OUT NOCOPY   VARCHAR2,
  x_msg_count       OUT NOCOPY   NUMBER);

END;

 

/
