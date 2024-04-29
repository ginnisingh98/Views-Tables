--------------------------------------------------------
--  DDL for Package Body MTH_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_COMMON_PKG" AS
/*$Header: mthcmtbb.pls 120.0.12010000.1 2010/03/15 21:48:36 lvenkatr noship $*/

PROCEDURE CALL_NTB_UPLOAD_COMPOSITE_PK(P_TARGET IN VARCHAR2) IS
--initialize variables here
v_entity VARCHAR2(200) := p_target;

BEGIN

	/* Call NTB Upload for Composite Key from here.  Since OWB does not
 * support types other than Record, this is a workaround by which MTH_UDA_PKG
 * does not need to be imported into OWB.  This package will be imported into
 * OWB instead. */

	MTH_UDA_PKG.NTB_UPLOAD_COMPOSITE_PK(v_entity);

EXCEPTION
WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20003,SQLERRM);
	ROLLBACK;

END; --End NTB_UPLOAD_COMPOSITE_PK

END MTH_COMMON_PKG;

/
