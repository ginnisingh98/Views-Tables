--------------------------------------------------------
--  DDL for Package CSL_JTF_TASK_REFS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_JTF_TASK_REFS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslteacs.pls 115.3 2002/11/08 14:01:12 asiegers ship $ */
PROCEDURE CON_REQUEST_TASK_REFERENCES;

PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id   IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 );

END CSL_JTF_TASK_REFS_ACC_PKG;

 

/
