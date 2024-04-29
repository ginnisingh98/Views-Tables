--------------------------------------------------------
--  DDL for Package FA_STANDARD_DDL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_STANDARD_DDL_PKG" AUTHID CURRENT_USER as
/* $Header: faxsddls.pls 120.1.12010000.2 2009/07/19 13:00:57 glchen ship $ */

 procedure create_sequence(X_name varchar2,
			   X_start_num number,
			   X_max_num number default 2000000000,
			   X_Calling_Fn	VARCHAR2);

END FA_STANDARD_DDL_PKG;

/
