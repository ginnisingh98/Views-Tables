--------------------------------------------------------
--  DDL for Package BOM_OPEN_INTERFACE_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OPEN_INTERFACE_UTL" AUTHID CURRENT_USER AS
/* $Header: BOMUBOIS.pls 120.2 2005/09/08 09:22:11 dikrishn ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUBOIS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Open_Interface_Utl
--
--  NOTES
--
--  HISTORY
--
--  22-NOV-02	Vani Hymavathi	Initial Creation
--  01-JUN-05 Bhavnesh Patel  Added Batch Id
***************************************************************************/
G_Create         CONSTANT VARCHAR2(10) := 'CREATE'; -- transaction type
G_Update         CONSTANT VARCHAR2(10) := 'UPDATE'; -- transaction type
G_Delete         CONSTANT VARCHAR2(10) := 'DELETE'; -- transaction type
G_NoOp		 CONSTANT VARCHAR2(10) := 'NO_OP'; -- transaction type


FUNCTION Process_Header_Info (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN	NUMBER
)
    return INTEGER ;

FUNCTION Process_Comps_Info (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  NOCOPY VARCHAR2,
    p_batch_id  IN	NUMBER
)
    return INTEGER;

FUNCTION Process_Ref_Degs_Info  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  NOCOPY VARCHAR2,
    p_batch_id  IN	NUMBER
)
    return INTEGER;

FUNCTION Process_Sub_Comps_Info  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  NOCOPY VARCHAR2,
    p_batch_id  IN	NUMBER
)
    return INTEGER;

FUNCTION Process_Comp_Ops_Info  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN	NUMBER
   )
    return INTEGER;

FUNCTION Process_Revision_Info(
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_set_process_id  IN	NUMBER
  )
   return INTEGER;

--process entities with null batch id
FUNCTION Process_All_Entities(
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2
  )
   return INTEGER;

--process entities for given batch id
FUNCTION Process_All_Entities(
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN	NUMBER
  )
   return INTEGER;

END Bom_Open_Interface_Utl;

 

/
