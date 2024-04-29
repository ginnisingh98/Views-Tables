--------------------------------------------------------
--  DDL for Package WSM_JOBCOSTING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_JOBCOSTING_GRP" AUTHID CURRENT_USER AS
/* $Header: WSMGCSTS.pls 115.0 2003/07/23 01:19:34 vjambhek ship $ */

    PROCEDURE Insert_MaterialTxn(p_txn_id   IN NUMBER,
                                 x_err_code OUT NOCOPY NUMBER,
                                 x_err_buf  OUT NOCOPY VARCHAR2
                                );

    PROCEDURE Update_QtyIssued(p_txn_id    IN  NUMBER,
                               p_txn_type  IN  NUMBER,
                               x_err_code  OUT NOCOPY NUMBER,
                               x_err_buf   OUT NOCOPY VARCHAR2
                              );

END WSM_JobCosting_GRP;

 

/
