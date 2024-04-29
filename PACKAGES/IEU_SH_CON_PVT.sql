--------------------------------------------------------
--  DDL for Package IEU_SH_CON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_SH_CON_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVSHCS.pls 115.5 2003/08/24 05:19:12 parghosh ship $ */

type t_cursor IS REF CURSOR;

PROCEDURE IEU_SH_END_IDLE_TRANS(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2, p_agent_name in VARCHAR2, p_appl_name in VARCHAR2, p_timeout in NUMBER);

PROCEDURE IEU_SH_OPEN_CURSOR(l_applCursor IN OUT NOCOPY t_cursor, p_appl_name IN NUMBER);

END IEU_SH_CON_PVT;


 

/
