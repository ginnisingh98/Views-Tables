--------------------------------------------------------
--  DDL for Package EDR_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_CTX_PKG" AUTHID CURRENT_USER AS
/*  $Header: EDRSECXS.pls 120.0.12000000.1 2007/01/18 05:55:30 appldev ship $ */
	PROCEDURE set_secure_attr;

        --Bug 3468810: start
        PROCEDURE unset_secure_attr;
        --Bug 3468810: end
END edr_ctx_pkg;

 

/
