--------------------------------------------------------
--  DDL for Package JL_BR_SPED_DATA_EXTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_SPED_DATA_EXTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: jlbrascs.pls 120.0.12010000.1 2009/08/17 14:40:53 mkandula noship $ */
    PROCEDURE register_I200_I250(errbuf             OUT NOCOPY VARCHAR2,
                                 retcode            OUT NOCOPY NUMBER,
                                 p_ledger_id        GL_LEDGERS.LEDGER_ID%TYPE,
                                 p_legal_entity_id  XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
                                 p_establishment_id XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
                                 p_period_set_name  GL_LEDGERS.PERIOD_SET_NAME%TYPE,
                                 p_start_date       DATE,
                                 p_end_date         DATE,
                                 p_balancing_segment VARCHAR2,
                                 p_account_segment VARCHAR2,
                                 p_cost_center_segment VARCHAR2,
                                 p_bookkeeping_type VARCHAR2,
                                 p_concurrent_request_id NUMBER);

    PROCEDURE register_I015    (errbuf             OUT NOCOPY VARCHAR2,
                                retcode            OUT NOCOPY NUMBER,
                                p_ledger_id        GL_LEDGERS.LEDGER_ID%TYPE,
                                p_legal_entity_id  XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
                                p_establishment_id XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
                                p_period_set_name  GL_LEDGERS.PERIOD_SET_NAME%TYPE,
                                p_start_date       DATE,
                                p_end_date         DATE,
                                p_balancing_segment VARCHAR2,
                                p_account_segment VARCHAR2,
                                p_cost_center_segment VARCHAR2,
                                p_bookkeeping_type VARCHAR2,
                                p_concurrent_request_id NUMBER);

END JL_BR_SPED_DATA_EXTRACT_PUB;

/
