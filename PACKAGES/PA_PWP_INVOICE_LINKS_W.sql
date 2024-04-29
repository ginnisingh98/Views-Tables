--------------------------------------------------------
--  DDL for Package PA_PWP_INVOICE_LINKS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PWP_INVOICE_LINKS_W" AUTHID CURRENT_USER as
  /* $Header: painvlns.pls 120.0.12010000.1 2008/11/14 13:03:05 svivaram noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy pa_pwp_invoice_links.link_tab, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t pa_pwp_invoice_links.link_tab, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure del_invoice_link(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure add_invoice_link(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end pa_pwp_invoice_links_w;

/
