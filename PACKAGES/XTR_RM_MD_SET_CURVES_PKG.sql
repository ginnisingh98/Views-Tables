--------------------------------------------------------
--  DDL for Package XTR_RM_MD_SET_CURVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_RM_MD_SET_CURVES_PKG" AUTHID CURRENT_USER as
/* $Header: xtrmdscs.pls 120.1 2005/06/29 10:47:41 csutaria ship $ */

    PROCEDURE insert_row(p_rowid	    IN OUT NOCOPY VARCHAR2,
			 p_curve_code       IN VARCHAR2,
			 p_data_side        IN VARCHAR2,
			 p_interpolation    IN VARCHAR2,
			 p_set_code 	    IN VARCHAR2,
			 p_created_by 	    IN NUMBER,
			 p_creation_date    IN DATE,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER);



    PROCEDURE update_row(p_rowid	    IN VARCHAR2,
			 p_curve_code       IN VARCHAR2,
			 p_data_side        IN VARCHAR2,
			 p_interpolation    IN VARCHAR2,
			 p_set_code 	    IN VARCHAR2,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER);


    PROCEDURE lock_row	(p_rowid	    IN VARCHAR2,
			 p_curve_code       IN VARCHAR2,
			 p_data_side        IN VARCHAR2,
			 p_interpolation    IN VARCHAR2,
			 p_set_code 	    IN VARCHAR2);


    PROCEDURE delete_row(p_rowid IN VARCHAR2);


END XTR_RM_MD_SET_CURVES_PKG;

 

/
