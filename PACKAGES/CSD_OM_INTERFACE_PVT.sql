--------------------------------------------------------
--  DDL for Package CSD_OM_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_OM_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvomts.pls 115.3 2004/02/17 20:09:54 vlakaman noship $ */

  PROCEDURE PROCESS_RMA
     (errbuf		        OUT NOCOPY VARCHAR2,
      retcode		        OUT NOCOPY VARCHAR2,
      p_inventory_org_id    	  IN         NUMBER,
      p_subinventory_name       IN         VARCHAR2) ;

  PROCEDURE Get_Party_site_id
     (p_site_use_type           IN         VARCHAR2,
      p_cust_site_use_id        IN         NUMBER ,
      x_party_site_use_id       OUT NOCOPY VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2  );


END CSD_OM_INTERFACE_PVT;

 

/
