--------------------------------------------------------
--  DDL for Package JTF_TTY_NACCT_SALES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_NACCT_SALES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfnacss.pls 120.0 2005/06/02 18:20:38 appldev ship $ */
/*===========================================================================+
 |               Copyright (c) 2002 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
+===========================================================================*/
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_NACCT_SALES_PUB
--    ---------------------------------------------------
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--
--    HISTORY
--
--    End of Comments
--
--*******************************************************
--    Start of Comments
--*******************************************************

--*******************************************************
-- RECORD TYPES

TYPE SALESREP_RSC_REC_TYPE IS RECORD(
    resource_id     NUMBER,
    group_id        NUMBER,
    role_code       VARCHAR2(300),
    mgr_resource_id     NUMBER,
    mgr_group_id        NUMBER,
    mgr_role_code       VARCHAR2(300),
    resource_type   VARCHAR2(300),
    attribute1      VARCHAR2(300),
    attribute2      VARCHAR2(300),
    attribute3      VARCHAR2(300),
    attribute4      VARCHAR2(300),
    attribute5      VARCHAR2(300),
    attribute6      VARCHAR2(300),
    attribute7      VARCHAR2(300),
    attribute8      VARCHAR2(300)
);

TYPE SALESREP_RSC_TBL_TYPE IS TABLE OF SALESREP_RSC_REC_TYPE;

TYPE AFFECTED_PARTY_REC_TYPE IS RECORD(
    party_id            NUMBER,
    named_account_id    NUMBER,
    terr_group_account_id    NUMBER,
    attribute1          VARCHAR2(300),
    attribute2          VARCHAR2(300),
    attribute3          VARCHAR2(300),
    attribute4          VARCHAR2(300),
    attribute5          VARCHAR2(300),
    attribute6          VARCHAR2(300),
    attribute7          VARCHAR2(300),
    attribute8          VARCHAR2(300)
);

TYPE AFFECTED_PARTY_TBL_TYPE IS TABLE OF AFFECTED_PARTY_REC_TYPE;


--*******************************************************
-- GLOBAL TYPE INSTANCES

G_ADD_SALESREP_TBL SALESREP_RSC_TBL_TYPE;
G_REM_SALESREP_TBL SALESREP_RSC_TBL_TYPE;
G_AFFECT_PARTY_TBL AFFECTED_PARTY_TBL_TYPE;


--*******************************************************
-- APIS

PROCEDURE UPDATE_SALES_TEAM(
      p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN         VARCHAR2  := FND_API.G_FALSE,
      p_SQL_Trace             IN         VARCHAR2,
      p_Debug_Flag            IN         VARCHAR2,
      x_return_status         OUT NOCOPY         VARCHAR2,
      x_msg_count             OUT NOCOPY        NUMBER,
      x_msg_data              OUT NOCOPY        VARCHAR2,

      p_user_resource_id      IN          NUMBER,
      p_terr_group_id         IN          NUMBER,
      p_user_attribute1       IN          VARCHAR2,
      p_user_attribute2       IN          VARCHAR2,
      p_added_rscs_tbl        IN          SALESREP_RSC_TBL_TYPE,
      p_removed_rscs_tbl      IN          SALESREP_RSC_TBL_TYPE,
      p_affected_parties_tbl  IN          AFFECTED_PARTY_TBL_TYPE,
      ERRBUF                  OUT NOCOPY         VARCHAR2,
      RETCODE                 OUT NOCOPY        VARCHAR2
  );



END JTF_TTY_NACCT_SALES_PUB;

 

/
