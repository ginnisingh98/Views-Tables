--------------------------------------------------------
--  DDL for Package FEM_AW_SNAPSHOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_AW_SNAPSHOT_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_aw_snapshot.pls 120.1 2005/07/07 15:21:33 appldev ship $

PROCEDURE Create_Snapshot
(x_err_code OUT NOCOPY NUMBER,
 x_num_msg  OUT NOCOPY NUMBER
);

END FEM_AW_Snapshot_Pkg;

 

/
