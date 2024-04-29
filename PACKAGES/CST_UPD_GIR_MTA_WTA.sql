--------------------------------------------------------
--  DDL for Package CST_UPD_GIR_MTA_WTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_UPD_GIR_MTA_WTA" AUTHID CURRENT_USER AS
/* $Header: CSTGIRMWS.pls 120.0.12010000.1 2008/10/28 18:53:25 hyu noship $ */


PROCEDURE cst_sl_link_upg_mta (p_je_batch_id   IN NUMBER);

PROCEDURE cst_sl_link_upg_wta (p_je_batch_id   IN NUMBER);

PROCEDURE update_mta_wta
(errbuf           OUT  NOCOPY VARCHAR2,
 retcode          OUT  NOCOPY NUMBER,
 p_from_date      IN          VARCHAR2,
 p_to_date        IN          VARCHAR2,
 p_ledger_id      IN          NUMBER);

END;

/
