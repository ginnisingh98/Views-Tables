--------------------------------------------------------
--  DDL for Package JG_ZZ_TA_CC_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_TA_CC_RANGES_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzztacs.pls 115.1 2002/11/15 17:08:32 arimai ship $ */

PROCEDURE Overlap(	 X_Rowid                     	VARCHAR2
                  	,X_rule_set_id		      	NUMBER
                  	,X_cc_range_low	      		VARCHAR2
                  	,X_cc_range_high             	VARCHAR2);

PROCEDURE Insert_Row( 	 X_rowid		IN OUT NOCOPY	VARCHAR2
			,X_cc_range_id		IN OUT NOCOPY	NUMBER
			,X_rule_set_id		IN OUT NOCOPY  NUMBER
			,X_cc_range_low			VARCHAR2
			,X_cc_range_high		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_description			VARCHAR2
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 );


PROCEDURE Update_Row( 	 X_rowid		      	VARCHAR2
			,X_cc_range_id		      	NUMBER
			,X_rule_set_id		        NUMBER
			,X_cc_range_low			VARCHAR2
			,X_cc_range_high		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_description			VARCHAR2
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 );

PROCEDURE Delete_Row( X_Rowid		VARCHAR2 );


PROCEDURE Lock_Row( 	 X_rowid		        VARCHAR2
			,X_cc_range_id		        NUMBER
			,X_rule_set_id		        NUMBER
			,X_cc_range_low			VARCHAR2
			,X_cc_range_high		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_description			VARCHAR2
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 );


END JG_ZZ_TA_CC_RANGES_PKG;

 

/
