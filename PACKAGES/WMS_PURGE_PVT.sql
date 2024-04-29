--------------------------------------------------------
--  DDL for Package WMS_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSPURGS.pls 120.4 2006/08/10 11:13:08 bradha ship $*/

PROCEDURE Check_Purge_LPNs (
  p_api_version     IN         NUMBER
, p_init_msg_list   IN         VARCHAR2 := fnd_api.g_false
, p_commit          IN         VARCHAR2 := fnd_api.g_false
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
, p_caller          IN         VARCHAR2
, p_lock_flag       IN         VARCHAR2
, p_lpn_id_table    IN OUT NOCOPY WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType
);

PROCEDURE Purge_LPNs (
  p_api_version     IN         NUMBER
, p_init_msg_list   IN         VARCHAR2 := fnd_api.g_false
, p_commit          IN         VARCHAR2 := fnd_api.g_false
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
, p_caller          IN         VARCHAR2
, p_lpn_id_table    IN         WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType
, p_purge_count     IN OUT NOCOPY WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType
);

PROCEDURE purge_wms(
                    	x_errbuf        OUT NOCOPY VARCHAR2,
			x_retcode      	OUT NOCOPY NUMBER,
			p_purge_date 	IN      VARCHAR2, -- Bug Fix 4496028
			p_orgid         IN      NUMBER,
			p_purge_name 	IN      VARCHAR2,
                        p_purge_age     IN      NUMBER,
                        p_purge_type    IN      NUMBER );
end WMS_PURGE_PVT;

 

/
