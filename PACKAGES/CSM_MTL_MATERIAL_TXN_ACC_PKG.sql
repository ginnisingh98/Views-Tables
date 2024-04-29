--------------------------------------------------------
--  DDL for Package CSM_MTL_MATERIAL_TXN_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MTL_MATERIAL_TXN_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csmmtacs.pls 120.2.12010000.2 2008/10/20 10:42:49 trajasek ship $ */

PROCEDURE Insert_MTL_Mat_Transaction(
                                      p_user_id         NUMBER,
                                      p_transaction_id     NUMBER
                                    );

PROCEDURE Update_MTL_Mat_Transaction(
                                      p_user_id         NUMBER,
                                      p_transaction_id     NUMBER
                                    );

PROCEDURE Delete_MTL_Mat_Transaction(
                                      p_user_id         NUMBER,
                                      p_transaction_id     NUMBER
                                    );

PROCEDURE DELETE_ALL_ACC_RECORDS(     p_user_id IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2
		  );

PROCEDURE Refresh_Mat_Txn_Acc(  p_status OUT NOCOPY VARCHAR2,
                                p_message OUT NOCOPY VARCHAR2
		  );


--Called when a new user is created
PROCEDURE get_new_user_mat_txn( p_user_id IN NUMBER);

END CSM_MTL_MATERIAL_TXN_ACC_PKG;

/
