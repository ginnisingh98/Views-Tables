--------------------------------------------------------
--  DDL for Package ENG_ENGINEERING_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ENGINEERING_CHANGES_PKG" AUTHID CURRENT_USER as
/* $Header: engpecos.pls 115.2 2003/02/07 09:04:47 rbehal ship $ */



PROCEDURE Check_Unique(	X_Rowid VARCHAR2,
		      	X_Change_Notice VARCHAR2,
			X_Organization_Id NUMBER );


PROCEDURE Delete_Row( X_Rowid VARCHAR2,
	  	      X_Change_Notice VARCHAR2,
	 	      X_Organization_Id NUMBER );

PROCEDURE Delete_ECO_Revisions( X_Change_Notice VARCHAR2,
				X_Organization_Id NUMBER );


END ENG_ENGINEERING_CHANGES_PKG ;

 

/
