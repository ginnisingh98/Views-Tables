--------------------------------------------------------
--  DDL for Package CSM_MTL_UNIT_TXN_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MTL_UNIT_TXN_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csmutacs.pls 120.0.12010000.2 2008/10/20 10:44:57 trajasek ship $ */

PROCEDURE Insert_MTL_Unit_Trans(   p_user_id         NUMBER,
                                   p_transaction_id  NUMBER
                                );

PROCEDURE Update_MTL_Unit_Trans(    p_user_id         NUMBER,
                                    p_transaction_id  NUMBER
                                );

PROCEDURE Delete_MTL_Unit_Trans(    p_user_id         NUMBER,
                                    p_transaction_id  NUMBER
                               );

PROCEDURE DELETE_ALL_ACC_RECORDS(   p_user_id IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2
                              );

END CSM_MTL_UNIT_TXN_ACC_PKG;

/
