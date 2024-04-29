--------------------------------------------------------
--  DDL for Package PON_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_OPT_PKG" AUTHID CURRENT_USER AS
-- $Header: PONOPTS.pls 120.0 2007/07/26 13:12:00 ukottama noship $

PROCEDURE VERIFY_OPT_RESULT(p_scenario_id  IN NUMBER,x_status    OUT NOCOPY VARCHAR2);

-- Will Store the bid_number, line_number combination
TYPE PON_PROB_LINE IS RECORD (
 SCENARIO_ID                              NUMBER,
 BID_NUMBER                               NUMBER,
 LINE_NUMBER                              NUMBER,
 AWARD_QUANTITY                           NUMBER,
 AWARD_PRICE                              NUMBER,
 CREATION_DATE                            DATE,
 CREATED_BY                               NUMBER,
 LAST_UPDATE_DATE                         DATE,
 LAST_UPDATED_BY                          NUMBER,
 LAST_UPDATE_LOGIN                        NUMBER,
 AWARD_SHIPMENT_NUMBER                    NUMBER,
 INDICATOR_VALUE                          NUMBER,
 FIXED_AMOUNT_COMPONENT                          NUMBER
);

TYPE t_prob_lines IS TABLE OF PON_PROB_LINE INDEX BY BINARY_INTEGER;

-- Constants for mode values
g_fnd_debug     CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name      CONSTANT VARCHAR2(50) := 'PON_OPT_PKG';
g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

END PON_OPT_PKG;

/
