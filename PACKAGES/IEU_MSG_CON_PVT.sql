--------------------------------------------------------
--  DDL for Package IEU_MSG_CON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_MSG_CON_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVMSCS.pls 120.0 2005/06/02 16:02:18 appldev noship $ */


PROCEDURE IEU_MSG_DEL_MESSAGES(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT  NOCOPY VARCHAR2, p_last_update_date in date);

end ieu_msg_con_pvt;

 

/
