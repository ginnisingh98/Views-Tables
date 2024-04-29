--------------------------------------------------------
--  DDL for Package Body GLIQAVG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GLIQAVG_PKG" AS
/* $Header: gliqavgb.pls 120.2 2005/05/05 01:18:54 kvora ship $ */


	PROCEDURE set_ccid ( X_code_combination_id    	NUMBER) IS
	BEGIN
        	GLIQAVG_PKG.code_combination_id := X_code_combination_id;
	END set_ccid;

	PROCEDURE set_template_id ( X_template_id    	NUMBER) IS
	BEGIN
        	GLIQAVG_PKG.template_id := X_template_id;
	END set_template_id;

	PROCEDURE set_factor ( X_factor    	NUMBER) IS
	BEGIN
        	GLIQAVG_PKG.factor := X_factor;
	END set_factor;

	FUNCTION	get_ccid	RETURN NUMBER IS
        BEGIN
                RETURN GLIQAVG_pkg.code_combination_id;
        END get_ccid;

	FUNCTION	get_template_id	RETURN NUMBER IS
        BEGIN
                RETURN GLIQAVG_pkg.template_id;
        END get_template_id;

	FUNCTION	get_factor	RETURN NUMBER IS
        BEGIN
                RETURN GLIQAVG_pkg.factor;
        END get_factor;

END GLIQAVG_PKG;

/
