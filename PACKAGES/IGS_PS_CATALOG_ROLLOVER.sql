--------------------------------------------------------
--  DDL for Package IGS_PS_CATALOG_ROLLOVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_CATALOG_ROLLOVER" AUTHID CURRENT_USER AS
/* $Header: IGSPS75S.pls 115.5 2002/11/29 03:11:17 nsidana ship $ */

PROCEDURE catalog_rollover (
errbuf  out NOCOPY  varchar2,
retcode out NOCOPY  NUMBER,
p_old_catalog_version  in IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
p_new_catalog_version in IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
p_override_flag in VARCHAR2,
p_debug_flag in VARCHAR2,
p_org_id IN NUMBER);
end IGS_PS_CATALOG_ROLLOVER;

 

/
