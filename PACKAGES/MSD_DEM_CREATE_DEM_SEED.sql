--------------------------------------------------------
--  DDL for Package MSD_DEM_CREATE_DEM_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_CREATE_DEM_SEED" AUTHID CURRENT_USER AS
/* $Header: msddemcrdemseeds.pls 120.1.12000000.2 2007/09/25 06:36:09 syenamar noship $ */

UOM_NAME		VARCHAR2(6) 	:= 'EBSUOM';
CURRENCY_NAME		VARCHAR2(11) 	:= 'EBSCURRENCY';
PRICELIST_NAME		VARCHAR2(12) 	:= 'EBSPRICELIST';
DEMANTRA_SCHEMA		VARCHAR2(20);
INTG_TABLE              VARCHAR2(30)    := 'MSD_DEM_PRICE_LIST';

procedure create_dem_seed_data(errbuf	OUT NOCOPY VARCHAR2,
			       retcode	OUT NOCOPY VARCHAR2,
           		       p_start_no           in  number,
           		       p_num_entities       in  number,
          		       P_entity_type        in  number default 0);

end;


 

/
