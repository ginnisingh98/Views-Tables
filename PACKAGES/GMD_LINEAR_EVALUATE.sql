--------------------------------------------------------
--  DDL for Package GMD_LINEAR_EVALUATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_LINEAR_EVALUATE" AUTHID CURRENT_USER AS
/* $Header: GMDLPEXS.pls 115.0 2003/09/17 15:40:52 txdaniel noship $ */

   TYPE row IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE matrix IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


   PROCEDURE Substitute (P_mx 		IN OUT NOCOPY	Matrix
                        ,P_n 		IN		Number
                        ,x_status  	OUT NOCOPY   	VARCHAR2);

   PROCEDURE Calc_Mags (P_Mx 		IN  		Matrix
                       ,P_count 	IN  		Number
                       ,X_row 		OUT NOCOPY	Row
                       ,x_status  	OUT NOCOPY   	VARCHAR2);


   PROCEDURE Find_Max (P_mx 	IN 		Matrix
                   ,P_s 	IN 		row
                   ,P_j 	IN 		NUMBER
                   ,P_n 	IN 		NUMBER
                   ,X_result	OUT NOCOPY	Row
                   ,X_row	OUT NOCOPY	NUMBER
                   ,x_status  	OUT NOCOPY   	VARCHAR2);

   PROCEDURE Gauss_Pivot(P_mx 		IN OUT NOCOPY	Matrix
                        ,P_s 		IN 		row
                        ,P_current 	IN 		NUMBER
                        ,P_n 		IN 		NUMBER
                        ,x_status  	OUT NOCOPY   	VARCHAR2);

   PROCEDURE Eliminate (P_mx 		IN OUT NOCOPY	Matrix
                       ,P_s 		IN 		Row
                       ,P_n 		IN 		NUMBER
                       ,x_status  	OUT NOCOPY   	VARCHAR2);

   PROCEDURE Gauss (P_mx 	IN  		Matrix
                   ,P_n 	IN  		NUMBER
                   ,X_result 	OUT NOCOPY	Row
                   ,x_status  	OUT NOCOPY   	VARCHAR2) ;

   PROCEDURE Test_Gauss;

END GMD_LINEAR_EVALUATE;

 

/
