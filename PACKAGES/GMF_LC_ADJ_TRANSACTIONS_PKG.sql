--------------------------------------------------------
--  DDL for Package GMF_LC_ADJ_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_LC_ADJ_TRANSACTIONS_PKG" AUTHID CURRENT_USER AS
/*  $Header: GMFLCATS.pls 120.0.12010000.1 2009/08/14 19:43:39 rpatangy noship $ */
--****************************************************************************************************
--*                                                                                                  *
--* Oracle Process Manufacturing                                                                     *
--* ============================                                                                     *
--*                                                                                                  *
--* Package GMF_LC_ADJ_TRANSACTIONS_PKG                                                              *
--* ---------------------------                                                                      *
--* Description:                                                                                     *
--*                                                                                                  *
--* Author:  OPM Development EMEA                                                                    *
--* Date:                                                                                            *
--*                                                                                                  *
--* History                                                                                          *
--****************************************************************************************************

PROCEDURE process_lc_adjustments(
                        errbuf                   OUT NOCOPY VARCHAR2,
                        retcode                  OUT NOCOPY VARCHAR2,
                        p_le_id                   IN NUMBER,
                        p_from_organization_id    IN NUMBER,
                        p_to_organization_id      IN NUMBER,
                        p_from_inventory_item_id  IN NUMBER,
                        p_to_inventory_item_id    IN NUMBER,
                        p_start_date              IN VARCHAR2,
                        p_end_date                IN VARCHAR2) ;

END gmf_lc_adj_transactions_pkg;

/
