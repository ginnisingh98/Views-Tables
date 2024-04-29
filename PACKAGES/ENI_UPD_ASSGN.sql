--------------------------------------------------------
--  DDL for Package ENI_UPD_ASSGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_UPD_ASSGN" AUTHID CURRENT_USER AS
/* $Header: ENIIASGS.pls 115.0 2003/07/01 14:50:26 dsakalle noship $  */

-- This Public Procedure is used to Update Item Assignment flag in denorm table
PROCEDURE UPDATE_ASSGN_FLAG(
      p_new_category_id  IN NUMBER,
      p_old_category_id  IN NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2);

END ENI_UPD_ASSGN;

 

/
