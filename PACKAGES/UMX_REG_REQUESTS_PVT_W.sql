--------------------------------------------------------
--  DDL for Package UMX_REG_REQUESTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_REG_REQUESTS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: UMXRGRWS.pls 115.4 2004/07/09 20:32:10 kching noship $ */
  procedure is_username_available(p_username  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure update_reg_request(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  VARCHAR2
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  NUMBER
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  DATE
    , p0_a8 in out nocopy  DATE
    , p0_a9 in out nocopy  VARCHAR2
    , p0_a10 in out nocopy  VARCHAR2
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  VARCHAR2
  );
end umx_reg_requests_pvt_w;

 

/
