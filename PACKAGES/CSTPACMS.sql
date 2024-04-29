--------------------------------------------------------
--  DDL for Package CSTPACMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACMS" AUTHID CURRENT_USER AS
/* $Header: CSTACMSS.pls 115.8 2002/11/08 00:57:51 awwang ship $ */

FUNCTION move_snapshot(
          l_txn_temp_id         IN      NUMBER,
          l_txn_id              IN      NUMBER,
          err_num               OUT NOCOPY     NUMBER,
          err_code              OUT NOCOPY     VARCHAR2,
          err_msg               OUT NOCOPY     VARCHAR2)
RETURN INTEGER;

FUNCTION validate_snap_interface(
         l_txn_interface_id  	 IN   NUMBER,
         l_interface_table	 IN   NUMBER,
         l_primary_quantity	  IN   NUMBER,
         err_num             	 OUT NOCOPY  NUMBER,
         err_code                OUT NOCOPY  VARCHAR2,
         err_msg             	 OUT NOCOPY  VARCHAR2)
RETURN INTEGER;

FUNCTION move_snapshot_to_temp(
          l_txn_interface_id      IN   NUMBER,
          l_txn_temp_id           IN   NUMBER,
          l_interface_table       IN   NUMBER,
          err_num                 OUT NOCOPY  NUMBER,
          err_code                OUT NOCOPY  VARCHAR2,
          err_msg                 OUT NOCOPY  VARCHAR2)
RETURN INTEGER;

FUNCTION validate_move_snap_to_temp(
          l_txn_interface_id      IN   NUMBER,
          l_txn_temp_id           IN   NUMBER,
          l_interface_table       IN   NUMBER,
          l_primary_quantity	  IN   NUMBER,
          err_num                 OUT NOCOPY  NUMBER,
          err_code                OUT NOCOPY  VARCHAR2,
          err_msg                 OUT NOCOPY  VARCHAR2)
RETURN INTEGER;

END CSTPACMS;

 

/
