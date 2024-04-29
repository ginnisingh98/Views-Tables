--------------------------------------------------------
--  DDL for Package JTF_TTY_ALIGN_WEBADI_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_ALIGN_WEBADI_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: jtftyaws.pls 120.0 2005/06/02 18:22:03 appldev ship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_GEO_WEBADI_INTERFACE_PKG
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to return a list of column in order of selectivity.
--      And create indices on columns in order of  input
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/20/2002    SHLI        Created
--
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************

 TYPE VARRAY_TYPE IS VARRAY(30) OF VARCHAR(360);
 TYPE NARRAY_TYPE IS VARRAY(30) OF NUMBER;



procedure POPULATE_INTERFACE(          p_userid         in varchar2,
                                       p_align_id       in varchar2,
                                       p_init_flag      in varchar2,
                                       x_seq            out NOCOPY varchar2);

G_USER          CONSTANT        VARCHAR2(60):=FND_GLOBAL.USER_ID;
G_LOGIN         CONSTANT        VARCHAR2(60):=fnd_global.LOGIN_ID;
g_pkg_name      CONSTANT        VARCHAR2(30) := 'JTF_TTY_ALIGN_WEBADI_INT_PKG';

TYPE Number_table_type IS TABLE OF NUMBER;

PROCEDURE UPDATE_ALIGNMENT_TEAM(
      p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN         VARCHAR2,
      p_SQL_Trace             IN         VARCHAR2,
      p_Debug_Flag            IN         VARCHAR2,
      p_alignment_id          IN          NUMBER,
      p_user_id               IN          NUMBER,
      p_user_attribute1       IN          VARCHAR2,
      p_added_rscs_tbl        IN          JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE,
      p_removed_rscs_tbl      IN          JTF_TTY_NACCT_SALES_PUB.SALESREP_RSC_TBL_TYPE,
      p_affected_parties_tbl  IN          JTF_TTY_NACCT_SALES_PUB.AFFECTED_PARTY_TBL_TYPE,
      x_return_status         OUT  NOCOPY       VARCHAR2,
      x_msg_count             OUT  NOCOPY       NUMBER,
      x_msg_data              OUT  NOCOPY       VARCHAR2
  );



END JTF_TTY_ALIGN_WEBADI_INT_PKG;

 

/
