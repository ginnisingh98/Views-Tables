--------------------------------------------------------
--  DDL for Package AMS_BOM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_BOM_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswboms.pls 115.8 2002/11/11 22:07:10 abhola ship $ */
  procedure ams_process_bom(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_last_update_date  date
    , p_last_update_by  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a0  DATE := fnd_api.g_miss_date
    , p8_a1  DATE := fnd_api.g_miss_date
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  NUMBER := 0-1962.0724
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
  );
end ams_bom_pvt_w;

 

/
