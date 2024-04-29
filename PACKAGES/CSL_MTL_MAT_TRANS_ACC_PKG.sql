--------------------------------------------------------
--  DDL for Package CSL_MTL_MAT_TRANS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_MAT_TRANS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslmtacs.pls 115.7 2002/11/08 14:02:15 asiegers ship $ */

PROCEDURE Insert_MTL_Mat_Transaction(
                                      p_resource_id         NUMBER,
                                      p_subinventory_code  VARCHAR2,
                                      p_organization_id     NUMBER
                                    );

PROCEDURE Update_MTL_Mat_Transaction(
                                      p_resource_id         NUMBER,
                                      p_subinventory_code  VARCHAR2,
                                      p_organization_id     NUMBER
                                    );

PROCEDURE Delete_MTL_Mat_Transaction(
                                      p_resource_id         NUMBER,
                                      p_subinventory_code  VARCHAR2,
                                      p_organization_id     NUMBER
                                    );

PROCEDURE DELETE_ALL_ACC_RECORDS(     p_resource_id IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2
		  );

END CSL_MTL_MAT_TRANS_ACC_PKG;

 

/
