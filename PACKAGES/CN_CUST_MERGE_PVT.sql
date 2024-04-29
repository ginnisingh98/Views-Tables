--------------------------------------------------------
--  DDL for Package CN_CUST_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CUST_MERGE_PVT" AUTHID CURRENT_USER AS
  --$Header: cnvctmgs.pls 120.1 2007/10/20 11:16:49 rarajara ship $

procedure customer_merge (req_id NUMBER,
                          set_number NUMBER,
                          process_mode VARCHAR2);
procedure submit_merge_request(errbuf OUT nocopy VARCHAR2,
				     retcode OUT nocopy NUMBER);

END cn_cust_merge_pvt;

/
