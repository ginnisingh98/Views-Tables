--------------------------------------------------------
--  DDL for Package PSA_MFAR_ADJUSTMENT_COVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MFAR_ADJUSTMENT_COVER_PKG" AUTHID CURRENT_USER AS
/* $Header: PSAMFAHS.pls 115.2 2000/10/09 18:44:36 pkm ship      $ */

procedure INSERT_ROW (
		  X_ROWID 			in out VARCHAR2,
		  X_ADJUSTMENT_ID 		in NUMBER,
		  X_CUST_TRX_LINE_GL_DIST_ID 	in NUMBER,
		  X_MF_ADJUSTMENT_CCID 		in NUMBER,
		  X_AMOUNT 			in NUMBER,
		  X_PERCENT 			in NUMBER,
		  X_PREV_CUST_TRX_LINE_ID 	in NUMBER,
		  X_COMMENTS			in VARCHAR2,
		  X_MODE 			in VARCHAR2 default 'R' );

procedure LOCK_ROW (
		  X_ADJUSTMENT_ID 		in NUMBER,
		  X_CUST_TRX_LINE_GL_DIST_ID 	in NUMBER,
		  X_MF_ADJUSTMENT_CCID 		in NUMBER,
		  X_AMOUNT 			in NUMBER,
		  X_PERCENT 			in NUMBER,
		  X_PREV_CUST_TRX_LINE_ID 	in NUMBER,
		  X_COMMENTS			in VARCHAR2 );

procedure UPDATE_ROW (
		  X_ADJUSTMENT_ID 		in NUMBER,
		  X_CUST_TRX_LINE_GL_DIST_ID 	in NUMBER,
		  X_MF_ADJUSTMENT_CCID 		in NUMBER,
		  X_AMOUNT 			in NUMBER,
		  X_PERCENT 			in NUMBER,
		  X_PREV_CUST_TRX_LINE_ID 	in NUMBER,
		  X_COMMENTS			in VARCHAR2,
		  X_MODE 			in VARCHAR2 default 'R');

procedure ADD_ROW (
		  X_ROWID 			in out VARCHAR2,
		  X_ADJUSTMENT_ID 		in NUMBER,
		  X_CUST_TRX_LINE_GL_DIST_ID 	in NUMBER,
		  X_MF_ADJUSTMENT_CCID 		in NUMBER,
		  X_AMOUNT 			in NUMBER,
		  X_PERCENT 			in NUMBER,
		  X_PREV_CUST_TRX_LINE_ID 	in NUMBER,
		  X_COMMENTS			in VARCHAR2,
		  X_MODE 			in VARCHAR2 default 'R');

procedure DELETE_ROW (
		  X_ADJUSTMENT_ID 		in NUMBER,
		  X_CUST_TRX_LINE_GL_DIST_ID 	in NUMBER);

end PSA_MFAR_ADJUSTMENT_COVER_PKG;

 

/
