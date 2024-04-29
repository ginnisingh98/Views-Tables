--------------------------------------------------------
--  DDL for Package Body EDR_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_CTX_PKG" AS
/*  $Header: EDRSECXB.pls 120.0.12000000.1 2007/01/18 05:55:27 appldev ship $ */
PROCEDURE set_secure_attr IS
begin
	DBMS_SESSION.SET_CONTEXT('edr_secure_ctx','secure','Y');
end;


--Bug 3468810: start
-- we need a new api to unset the secure context
PROCEDURE unset_secure_attr IS
begin
        DBMS_SESSION.SET_CONTEXT('edr_secure_ctx','secure','');
end;
--Bug 3468810i: end
end edr_ctx_pkg;

/
