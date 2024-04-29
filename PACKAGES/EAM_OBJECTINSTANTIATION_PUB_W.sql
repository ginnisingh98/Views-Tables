--------------------------------------------------------
--  DDL for Package EAM_OBJECTINSTANTIATION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OBJECTINSTANTIATION_PUB_W" AUTHID CURRENT_USER as
  /* $Header: EAMWOBIS.pls 115.1 2003/09/08 12:57:50 ashetye noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy eam_objectinstantiation_pub.association_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t eam_objectinstantiation_pub.association_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

end eam_objectinstantiation_pub_w;

 

/
