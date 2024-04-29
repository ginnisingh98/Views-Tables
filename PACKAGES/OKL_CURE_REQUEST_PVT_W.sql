--------------------------------------------------------
--  DDL for Package OKL_CURE_REQUEST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_REQUEST_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEREQS.pls 120.1 2005/09/30 20:40:52 cklee noship $ */
  procedure send_cure_request(errbuf out nocopy  VARCHAR2
    , retcode out nocopy  NUMBER
    , p_vendor_number  NUMBER
    , p_report_number  VARCHAR2
    , p_report_date  date
  );
end okl_cure_request_pvt_w;

 

/
