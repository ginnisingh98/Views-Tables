--------------------------------------------------------
--  DDL for Package FA_MASS_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_RET_PKG" AUTHID CURRENT_USER as
/* $Header: faxmres.pls 120.2.12010000.2 2009/07/19 09:56:39 glchen ship $ */

PROCEDURE Create_Mass_Retirements
               (errbuf                  OUT     NOCOPY 	VARCHAR2,
                retcode                 OUT     NOCOPY 	NUMBER,
                p_mass_retirement_id    IN      	NUMBER,
		p_mode			IN		VARCHAR2,
		p_extend_search		IN		VARCHAR2);




TYPE out_rec IS RECORD ( ASSET_NUMBER  	VARCHAR2(15));
TYPE out_tbl IS TABLE OF out_rec index by binary_integer;

END FA_MASS_RET_PKG;


/
