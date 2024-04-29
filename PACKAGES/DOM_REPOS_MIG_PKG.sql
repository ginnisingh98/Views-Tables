--------------------------------------------------------
--  DDL for Package DOM_REPOS_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_REPOS_MIG_PKG" AUTHID CURRENT_USER AS
/* $Header: DOMVRUGS.pls 120.1 2006/09/04 16:15:42 rkhasa noship $ */
PROCEDURE UPDATE_PATH (
p_short_name IN VARCHAR2,
p_domain IN VARCHAR2,
p_old_str IN varchar2,
p_new_str IN OUT NOCOPY varchar2 ,
x_msg IN OUT NOCOPY CLOB
);

PROCEDURE GET_NEW_PATH (
p_short_name IN VARCHAR2,
p_domain IN VARCHAR2,
p_old_str IN varchar2,
p_new_str IN OUT NOCOPY varchar2 ,
p_doc_id IN Number,
x_msg IN OUT NOCOPY varchar2
);

END DOM_REPOS_MIG_PKG;

 

/
