--------------------------------------------------------
--  DDL for Package EAM_COPY_BOM_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_COPY_BOM_PKG_W" AUTHID CURRENT_USER as
  /* $Header: EAMCPMRS.pls 120.2 2008/01/26 01:53:33 devijay ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy eam_copy_bom_pkg.t_bom_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t eam_copy_bom_pkg.t_bom_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy eam_copy_bom_pkg.t_component_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t eam_copy_bom_pkg.t_component_table, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure copy_to_bom(p_organization_id  NUMBER
    , p_organization_code  VARCHAR2
    , p_asset_number  VARCHAR2
    , p_asset_group_id  NUMBER
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , x_error_code out nocopy  NUMBER
  );
  procedure retrieve_asset_bom(p_organization_id  NUMBER
    , p_wip_entity_id  NUMBER
    , p_operation_seq_num  NUMBER
    , p_department_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_300
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_NUMBER_TABLE
    , x_error_code out nocopy  VARCHAR2
  );
end eam_copy_bom_pkg_w;

/
