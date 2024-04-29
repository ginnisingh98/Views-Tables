--------------------------------------------------------
--  DDL for Package PON_CONTRACTS_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_CONTRACTS_TL_PKG" AUTHID CURRENT_USER AS
/* $Header: PONCNTS.pls 120.0.12010000.3 2012/05/09 07:41:23 svalampa ship $ */

PROCEDURE add_language;

PROCEDURE copy_attachments(ENTITY_NAME VARCHAR2,
		           pk1 VARCHAR2,
		           pk2 VARCHAR2,
                           pk3 VARCHAR2,
			   pk4 VARCHAR2);

END pon_contracts_tl_pkg;

/
