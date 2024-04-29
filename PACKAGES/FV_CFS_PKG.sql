--------------------------------------------------------
--  DDL for Package FV_CFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CFS_PKG" AUTHID CURRENT_USER AS
/* $Header: FVXCFSPS.pls 120.2.12010000.3 2010/03/31 12:04:26 yanasing ship $ */

PROCEDURE main (        errbuf                  OUT NOCOPY     VARCHAR2,
                        retcode                 OUT NOCOPY     NUMBER,
                        p_set_of_books_id       IN      NUMBER,
                        p_report_type           IN      VARCHAR2,
                        p_units                 IN      VARCHAR2,
                        p_period_name           IN      VARCHAR2,
                       	p_facts_rep_show	      IN	VARCHAR2 DEFAULT 'Y',
                        p_table_indicator       IN      VARCHAR2 DEFAULT 'O');

END FV_CFS_PKG ;

/
