--------------------------------------------------------
--  DDL for Package CSTPOMLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPOMLD" AUTHID CURRENT_USER AS
/* $Header: CSTOMLDS.pls 115.3 2002/05/09 15:07:29 pkm ship     $ */

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


END CSTPOMLD;

 

/
