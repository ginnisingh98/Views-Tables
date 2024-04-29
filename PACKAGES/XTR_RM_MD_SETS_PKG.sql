--------------------------------------------------------
--  DDL for Package XTR_RM_MD_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_RM_MD_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: xtrmdsts.pls 120.1 2005/06/29 10:43:58 badiredd ship $ */

    PROCEDURE insert_row(p_rowid	    IN OUT NOCOPY VARCHAR2,
			 p_set_code 	    IN VARCHAR2,
			 p_description 	    IN VARCHAR2,
			 p_authorized  	    IN VARCHAR2 DEFAULT 'Y',
			 p_fx_spot_side     IN VARCHAR2 DEFAULT 'MID',
			 p_bond_price_side  IN VARCHAR2 DEFAULT 'MID',
			 p_stock_price_side IN VARCHAR2 DEFAULT 'MID',
			p_attribute_category IN VARCHAR2 DEFAULT NULL,
			p_attribute1 IN VARCHAR2 DEFAULT NULL,
			p_attribute2 IN VARCHAR2 DEFAULT NULL,
			p_attribute3 IN VARCHAR2 DEFAULT NULL,
			p_attribute4 IN VARCHAR2 DEFAULT NULL,
			p_attribute5 IN VARCHAR2 DEFAULT NULL,
			p_attribute6 IN VARCHAR2 DEFAULT NULL,
			p_attribute7 IN VARCHAR2 DEFAULT NULL,
			p_attribute8 IN VARCHAR2 DEFAULT NULL,
			p_attribute9 IN VARCHAR2 DEFAULT NULL,
			p_attribute10 IN VARCHAR2 DEFAULT NULL,
			p_attribute11 IN VARCHAR2 DEFAULT NULL,
			p_attribute12 IN VARCHAR2 DEFAULT NULL,
			p_attribute13 IN VARCHAR2 DEFAULT NULL,
			p_attribute14 IN VARCHAR2 DEFAULT NULL,
			p_attribute15 IN VARCHAR2 DEFAULT NULL,
			 p_created_by 	    IN NUMBER,
			 p_creation_date    IN DATE,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER);


    PROCEDURE update_row(p_rowid	    IN VARCHAR2,
			 p_set_code 	    IN VARCHAR2,
			 p_description 	    IN VARCHAR2,
			 p_authorized  	    IN VARCHAR2 DEFAULT 'Y',
			 p_fx_spot_side     IN VARCHAR2 DEFAULT 'MID',
			 p_bond_price_side  IN VARCHAR2 DEFAULT 'MID',
                         p_stock_price_side  IN VARCHAR2 DEFAULT 'MID',
			p_attribute_category IN VARCHAR2 DEFAULT NULL,
			p_attribute1 IN VARCHAR2 DEFAULT NULL,
			p_attribute2 IN VARCHAR2 DEFAULT NULL,
			p_attribute3 IN VARCHAR2 DEFAULT NULL,
			p_attribute4 IN VARCHAR2 DEFAULT NULL,
			p_attribute5 IN VARCHAR2 DEFAULT NULL,
			p_attribute6 IN VARCHAR2 DEFAULT NULL,
			p_attribute7 IN VARCHAR2 DEFAULT NULL,
			p_attribute8 IN VARCHAR2 DEFAULT NULL,
			p_attribute9 IN VARCHAR2 DEFAULT NULL,
			p_attribute10 IN VARCHAR2 DEFAULT NULL,
			p_attribute11 IN VARCHAR2 DEFAULT NULL,
			p_attribute12 IN VARCHAR2 DEFAULT NULL,
			p_attribute13 IN VARCHAR2 DEFAULT NULL,
			p_attribute14 IN VARCHAR2 DEFAULT NULL,
			p_attribute15 IN VARCHAR2 DEFAULT NULL,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER);


    PROCEDURE lock_row	(p_rowid 	   IN VARCHAR2,
			 p_set_code 	   IN VARCHAR2,
			 p_description 	   IN VARCHAR2,
			 p_authorized  	   IN VARCHAR2,
			 p_fx_spot_side    IN VARCHAR2,
			 p_bond_price_side IN VARCHAR2);

    PROCEDURE delete_row(p_rowid IN VARCHAR2);


END XTR_RM_MD_SETS_PKG;

 

/
