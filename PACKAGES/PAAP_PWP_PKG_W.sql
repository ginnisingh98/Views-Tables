--------------------------------------------------------
--  DDL for Package PAAP_PWP_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAAP_PWP_PKG_W" AUTHID CURRENT_USER as
  /* $Header: parlhlds.pls 120.0.12010000.2 2009/07/21 14:34:03 anuragar noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy paap_pwp_pkg.invoiceid, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t paap_pwp_pkg.invoiceid, a0 out nocopy JTF_NUMBER_TABLE);

  procedure paap_release_hold(p_inv_tbl JTF_NUMBER_TABLE
    , p_rel_option  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure paap_apply_hold(p_inv_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end paap_pwp_pkg_w;

/
