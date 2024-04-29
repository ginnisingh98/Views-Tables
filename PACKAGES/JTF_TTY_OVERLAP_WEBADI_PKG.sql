--------------------------------------------------------
--  DDL for Package JTF_TTY_OVERLAP_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_OVERLAP_WEBADI_PKG" AUTHID CURRENT_USER AS
/* $Header: jtftyovs.pls 120.0 2005/06/02 18:22:04 appldev ship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_OVERLAP_WEBADI_PKG
--    ---------------------------------------------------
--    PURPOSE
--
--      Population of interface table for overlapping territory group report
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      08/13/2002    ARPATEL        Created
--
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************

G_USER          CONSTANT        VARCHAR2(60):=FND_GLOBAL.USER_ID;
G_LOGIN         CONSTANT        VARCHAR2(60):=fnd_global.LOGIN_ID;

procedure POPULATE_INTERFACE(          p_named_account_id in varchar2,
                                       p_terr_group_id    in varchar2,
                                       p_DUNS             in varchar2,
                                       p_userid          in varchar2,
                                       x_seq             out NOCOPY varchar2
                                       );

END JTF_TTY_OVERLAP_WEBADI_PKG;

 

/
