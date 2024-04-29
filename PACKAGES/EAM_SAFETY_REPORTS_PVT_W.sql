--------------------------------------------------------
--  DDL for Package EAM_SAFETY_REPORTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SAFETY_REPORTS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: EAMWSRPS.pls 120.0.12010000.1 2010/04/16 10:56:36 somitra noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy eam_safety_reports_pvt.eam_permit_tab_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t eam_safety_reports_pvt.eam_permit_tab_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  function getworkpermitreportxml(p0_a0 JTF_NUMBER_TABLE
    , p_file_attachment_flag  NUMBER
    , p_work_order_flag  NUMBER
  ) return clob;
  function convert_to_client_time(p_server_time  date
  ) return date;
end eam_safety_reports_pvt_w;

/
