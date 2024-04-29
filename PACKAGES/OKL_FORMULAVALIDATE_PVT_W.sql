--------------------------------------------------------
--  DDL for Package OKL_FORMULAVALIDATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAVALIDATE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEVALS.pls 120.1 2005/07/12 07:04:49 asawanka noship $ */
  procedure rosetta_table_copy_in_p29(t out nocopy okl_formulavalidate_pvt.fmaopd_tbl, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p29(t okl_formulavalidate_pvt.fmaopd_tbl, a0 out nocopy JTF_NUMBER_TABLE
    );

end okl_formulavalidate_pvt_w;

 

/
