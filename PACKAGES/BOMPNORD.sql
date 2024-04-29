--------------------------------------------------------
--  DDL for Package BOMPNORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPNORD" AUTHID CURRENT_USER as
/* $Header: BOMEORDS.pls 120.1 2005/06/21 04:11:33 appldev ship $ */

PROCEDURE bmxporder_explode_for_order (
	org_id			IN  NUMBER,
	copy_flag		IN  NUMBER DEFAULT 2,
	expl_type		IN  VARCHAR2 DEFAULT 'OPTIONAL',
	order_by 		IN  NUMBER DEFAULT 1,
	grp_id		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	session_id		IN  NUMBER DEFAULT 0,
	levels_to_explode 	IN  NUMBER DEFAULT 60,
	item_id			IN  NUMBER,
	comp_code               IN  VARCHAR2 DEFAULT '',
	starting_rev_date	IN  DATE DEFAULT SYSDATE - 1000,
	rev_date		IN  VARCHAR2 DEFAULT NULL,
	user_id			IN  NUMBER DEFAULT 0,
        commit_flag             IN  VARCHAR2 DEFAULT 'N',
	err_msg		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	error_code	        IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
        alt_bom_designator      IN VARCHAR2 DEFAULT NULL
) ;

END bompnord;

 

/
