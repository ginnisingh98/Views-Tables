--------------------------------------------------------
--  DDL for Package QPR_COLLECT_CURRENCY_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_COLLECT_CURRENCY_DATA" AUTHID CURRENT_USER AS
/* $Header: QPRUCCRS.pls 120.0 2007/10/11 13:08:26 agbennet noship $ */
procedure collect_currency_rates(errbuf out nocopy varchar2,
                                retcode out nocopy number,
                                p_instance_id in number,
                                p_date_from in varchar2,
                                p_date_to in varchar2);
END;



/
