--------------------------------------------------------
--  DDL for Package FND_AUDIT_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_AUDIT_UPDATE_PKG" AUTHID CURRENT_USER as
/*  $Header: fdaaddrs.pls 120.1 2007/02/02 00:50:48 appldev ship $ */

procedure FND_AUDIT_ROW_KEY(errbuf IN OUT NOCOPY varchar2, rc IN OUT NOCOPY varchar2, p_snm varchar2,p_taplid number,p_tabid number);

end FND_AUDIT_UPDATE_PKG;

/
