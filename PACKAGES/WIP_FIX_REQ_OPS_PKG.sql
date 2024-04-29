--------------------------------------------------------
--  DDL for Package WIP_FIX_REQ_OPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FIX_REQ_OPS_PKG" AUTHID CURRENT_USER AS
/* $Header: wiprqfxs.pls 115.6 2002/12/12 15:52:12 rmahidha ship $ */

  PROCEDURE Fix(X_Wip_Entity_Id          NUMBER,
                X_Organization_Id        NUMBER,
                X_Repetitive_Schedule_Id NUMBER,
                X_Entity_Start_Date      DATE);

END WIP_FIX_REQ_OPS_PKG;

 

/
