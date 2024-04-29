--------------------------------------------------------
--  DDL for Package AMS_DISCOVERER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DISCOVERER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswdiss.pls 115.8 2002/11/22 08:57:05 jieli ship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ams_discoverer_pvt.t_sqltable, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p1(t ams_discoverer_pvt.t_sqltable, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_2000);

end ams_discoverer_pvt_w;

 

/
