--------------------------------------------------------
--  DDL for Package CSD_MIG_SLABS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MIG_SLABS_PKG" AUTHID CURRENT_USER AS
/* $Header: csdslabs.pls 115.4 2002/11/19 01:59:51 swai noship $*/

   G_NO_OF_SLABS number   := 32; --@@optimal slabsize?
   G_MIN_SLAB_SIZE number := 100000; --@@Minimum size of the batch

   /*get min/max value of next available batch*/
    procedure get_table_slabs
        ( p_table_name in VARCHAR, -- Entity/table name CS_ESTIMATE_DETAILS
	     p_module      in VARCHAR, -- module id
          p_slab_number in NUMBER, --Number of the slab
		x_start_slab out NOCOPY NUMBER, --Start id of the slab
		x_end_slab out NOCOPY NUMBER ); --End id of the slab

    procedure create_table_slabs
        ( p_table_name in varchar, --Name of the table
	     p_module     in VARCHAR, -- module id
		p_pk_column in varchar, --Name of the primary key column
		p_no_of_slabs in number default G_NO_OF_SLABS, --Number of slabs to be created
		p_min_slab_size in number default G_MIN_SLAB_SIZE ); --Minimum slab size

END csd_mig_slabs_pkg;


 

/
