--------------------------------------------------------
--  DDL for Package MSD_DEM_COLLECT_RETURN_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COLLECT_RETURN_HISTORY" AUTHID CURRENT_USER AS
/* $Header: msddemcrhs.pls 120.1.12000000.2 2007/09/24 10:45:21 nallkuma noship $ */


PROCEDURE COLLECT_RETURN_HISTORY_DATA (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_sr_instance_id		IN         NUMBER,
      			p_collection_group      	IN         VARCHAR2 DEFAULT '-999', --jarora
      			p_collection_method     	IN         NUMBER,
      			p_date_range_type		IN	   NUMBER,
      			p_collection_window		IN	   NUMBER,
      			p_from_date			IN	   VARCHAR2,
      			p_to_date			IN	   VARCHAR2,
      			p_entity_name                   IN         VARCHAR2 DEFAULT NULL, --jarora
      			p_truncate                      IN         NUMBER DEFAULT 1 --sopjarora
      			);

end MSD_DEM_COLLECT_RETURN_HISTORY;

 

/
