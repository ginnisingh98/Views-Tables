--------------------------------------------------------
--  DDL for Package GL_AS_POST_UPG_CHK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AS_POST_UPG_CHK_PKG" AUTHID CURRENT_USER AS
/* $Header: gluasucs.pls 120.0 2005/05/04 17:35:34 djogg noship $ */

-- -------------------------
-- Public Procedures
-- -------------------------

-- PROCEDURE
--   Verify_Setup()
--
-- DESCRIPTION:
--   This is the main function of this ASM Post-upgrade Check package.
PROCEDURE Verify_Setup(  x_errbuf  IN OUT NOCOPY VARCHAR2
                       , x_retcode IN OUT NOCOPY VARCHAR2);

END GL_AS_POST_UPG_CHK_PKG;

 

/
