--------------------------------------------------------
--  DDL for Package CSTPMRGL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPMRGL" AUTHID CURRENT_USER AS
/* $Header: CSTMRGLS.pls 120.0.12010000.1 2008/07/24 17:21:17 appldev ship $ */

-- PROCEDURE
--  load_om_margin_data      Loads Margin data for OM
--
procedure load_om_margin_data(
I_FROM_DATE     IN      VARCHAR2,
I_TO_DATE       IN      VARCHAR2,
I_OVERLAP_DAYS  IN      NUMBER,
I_LOAD_OPTION   IN      NUMBER,
I_USER_ID       IN      NUMBER,
I_TRACE_MODE    IN      VARCHAR2);


END CSTPMRGL;

/
