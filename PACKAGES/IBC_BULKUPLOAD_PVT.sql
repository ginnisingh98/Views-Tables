--------------------------------------------------------
--  DDL for Package IBC_BULKUPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_BULKUPLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: ibcblkus.pls 120.0 2005/12/16 17:27 srrangar noship $ */

PROCEDURE BULKUPLOAD_PROCESS(p_bulkupload_id 	 		IN NUMBER
                            ,x_return_status            OUT NOCOPY VARCHAR2
                            ,x_msg_count                OUT NOCOPY NUMBER
                            ,x_msg_data                 OUT NOCOPY VARCHAR2);

END Ibc_Bulkupload_Pvt;

 

/
