--------------------------------------------------------
--  DDL for Package INV_3PL_BILLING_UNITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_3PL_BILLING_UNITS_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVBLUS.pls 120.0.12010000.2 2010/01/17 10:25:22 gjyoti noship $ */

    PROCEDURE CALCULATE_BILLING_UNITS
        (
            ERRBUF              OUT NOCOPY VARCHAR2 ,
            RETCODE             OUT NOCOPY NUMBER ,
            p_OU_id             IN NUMBER,
            p_client_id         IN NUMBER,
            p_rule_ID           IN NUMBER,
            p_contract_id       IN NUMBER,
            p_item_id           IN NUMBER,
            p_source_to_date    IN varchar2
        );

END INV_3PL_BILLING_UNITS_PVT;

/
