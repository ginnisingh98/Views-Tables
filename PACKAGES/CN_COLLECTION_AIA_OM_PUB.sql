--------------------------------------------------------
--  DDL for Package CN_COLLECTION_AIA_OM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECTION_AIA_OM_PUB" AUTHID CURRENT_USER AS
  /* $Header: CNPCLTROMS.pls 120.0.12010000.3 2009/07/01 06:47:21 rajukum noship $*/


  -- Function name  : get_exchange_rate
  -- Type : Public.
  -- Pre-reqs :

  FUNCTION get_exchange_rate(p_from_currency IN cn_aia_order_capture.amt_curcy_cd%TYPE,
                             p_conversion_date IN cn_aia_order_capture.processed_date%TYPE,
                             p_org_id IN cn_aia_order_capture.org_id%TYPE)
                              RETURN cn_aia_order_capture.exchange_rate%TYPE;


   -- Function name  : get_employee_number
  -- Type : Public.
  -- Pre-reqs :

   FUNCTION get_employee_number(p_salesrep_id IN cn_aia_order_capture.salesrep_id%TYPE,
                                p_org_id cn_aia_order_capture.org_id%TYPE)
                                  RETURN cn_aia_order_capture.employee_number%TYPE;

   -- API name  : pre_aia_om_load_process
  -- Type : Public.
  -- Pre-reqs :
  -- Usage :
  --+
  -- Desc  :
  --
  --

  PROCEDURE pre_aia_om_load_process(errbuf OUT nocopy VARCHAR2,
                                    retcode OUT nocopy NUMBER,
                                    p_org_id IN NUMBER
                                    );

  -- API name  : post_aia_om_load_process
  -- Type : Public.
  -- Pre-reqs :
  -- Usage :
  --+
  -- Desc  :
  --
  --
  PROCEDURE post_aia_om_load_process(x_return_status OUT nocopy VARCHAR2);



END CN_COLLECTION_AIA_OM_PUB;

/
