--------------------------------------------------------
--  DDL for Package PER_CAREER_PATHS_PKG_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAREER_PATHS_PKG_1" AUTHID CURRENT_USER as
/* $Header: pecpt01.pkh 115.0 99/07/17 18:51:56 porting ship $ */

procedure stb_del_val(p_cpath_id IN NUMBER);

procedure unique_chk(p_bgroup_id IN NUMBER,
                   p_name IN VARCHAR2,
                   p_rowid IN VARCHAR2);

procedure get_id(p_cpath_id IN OUT NUMBER);


end PER_CAREER_PATHS_PKG_1;

 

/
