--------------------------------------------------------
--  DDL for Package JTS_CONFIG_VER_STATUS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIG_VER_STATUS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtswcvss.pls 115.2 2002/03/22 19:08:06 pkm ship    $ */
  procedure any_version_replayed(p_api_version  NUMBER
    , p_config_id  NUMBER
    , x_replayed out  number
  );
  procedure in_replay_status(p_api_version  NUMBER
    , p_status  VARCHAR2
    , ddrosetta_retval_bool OUT NUMBER
  );
  procedure in_version_status(p_api_version  NUMBER
    , p_status  VARCHAR2
    , ddrosetta_retval_bool OUT NUMBER
  );
  procedure not_replayed(p_api_version  NUMBER
    , p_status  VARCHAR2
    , x_in_notreplayed out  number
  );
end jts_config_ver_status_pvt_w;

 

/
