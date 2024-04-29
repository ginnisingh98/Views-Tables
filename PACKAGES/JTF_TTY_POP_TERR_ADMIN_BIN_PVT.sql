--------------------------------------------------------
--  DDL for Package JTF_TTY_POP_TERR_ADMIN_BIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_POP_TERR_ADMIN_BIN_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvuabs.pls 120.0 2005/06/02 18:23:13 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_POP_TERR_ADMIN_BIN_PVT
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--
--
--
--
--    NOTES
--
--
--
--
--    HISTORY
--      09/15/02    JRADHAKR         CREATED
--
--
--    End of Comments
--


Procedure populate_catch_all_bin_info
( x_return_status                                OUT NOCOPY  VARCHAR2
, x_error_message                               OUT NOCOPY  VARCHAR2
);

Procedure populate_kpi_bin_info
( x_return_status                                OUT NOCOPY  VARCHAR2
, x_error_message                               OUT NOCOPY  VARCHAR2
);

Procedure Sync_terr_group
( x_return_status                               OUT NOCOPY  VARCHAR2
, x_error_message                               OUT NOCOPY  VARCHAR2
);

END  JTF_TTY_POP_TERR_ADMIN_BIN_PVT;

 

/
