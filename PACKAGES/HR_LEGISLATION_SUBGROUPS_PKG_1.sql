--------------------------------------------------------
--  DDL for Package HR_LEGISLATION_SUBGROUPS_PKG_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEGISLATION_SUBGROUPS_PKG_1" AUTHID CURRENT_USER as
/* $Header: pylgs01t.pkh 115.0 99/07/17 06:15:43 porting ship $ */

procedure b_check_duplicate_in (p_legis_code IN VARCHAR2,
                                 p_legis_sub IN VARCHAR2,
                                 p_rowid IN VARCHAR2);








end HR_LEGISLATION_SUBGROUPS_PKG_1;

 

/
