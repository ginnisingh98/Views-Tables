--------------------------------------------------------
--  DDL for Package WSMPCPSB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPCPSB" AUTHID CURRENT_USER as
/* $Header: WSMCPSBS.pls 120.1 2006/03/27 20:41:47 mprathap noship $ */

  PROCEDURE Check_Unique(X_rowid	           VARCHAR2,
			 X_co_product_group_id	   NUMBER,
                         X_co_product_id           NUMBER,
                         X_substitute_coprod_id    NUMBER);

  PROCEDURE Delete_substitutes (x_co_product_group_id     IN  NUMBER,
                               x_co_product_id           IN  NUMBER);

END WSMPCPSB;

 

/
