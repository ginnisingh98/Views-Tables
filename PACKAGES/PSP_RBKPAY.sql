--------------------------------------------------------
--  DDL for Package PSP_RBKPAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_RBKPAY" AUTHID CURRENT_USER AS
--$Header: PSPORRBS.pls 120.1 2006/08/04 23:15:49 vdharmap noship $
PROCEDURE rollback_paytrans( errbuf out NOCOPY varchar2,
			    retcode out NOCOPY varchar2,
			    p_period_type in varchar2,
			    p_time_period_id in number);


END PSP_RBKPAY;

/
