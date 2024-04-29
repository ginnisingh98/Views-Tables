--------------------------------------------------------
--  DDL for Package Body GMF_AR_PER_ORDER_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_PER_ORDER_CREDIT" AS
/* $Header: gmfcrlmb.pls 120.1 2005/09/08 09:07:26 sschinch noship $ */

        procedure PER_ORDER_CREDIT (cust_id               in out NOCOPY number,
                                    siteuseid             in out NOCOPY number,
                                    order_currency        in out NOCOPY varchar2,
                                    base_currency            out NOCOPY varchar2,
                                    cur_order_tot         in out NOCOPY number,
                                    total_outstand        in out NOCOPY number,
                                    trx_cr_limit             out NOCOPY number,
                                    total_cr_limit           out NOCOPY number,
                                    tolerance                out NOCOPY number,
                                    amt_exceeded_per_order   out NOCOPY number,
                                    amt_exceeded_total       out NOCOPY number,
                                    cr_check_status          out NOCOPY number,
                                    error_status             out NOCOPY number,
				                            ar_outstand              out NOCOPY number,
				                            porg_id		 in  out NOCOPY number) IS
          BEGIN
            null;
		      end PER_ORDER_CREDIT;

END GMF_AR_PER_ORDER_CREDIT;

/
