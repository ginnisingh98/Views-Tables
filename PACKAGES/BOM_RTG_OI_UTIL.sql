--------------------------------------------------------
--  DDL for Package BOM_RTG_OI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_OI_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUROIS.pls 120.1 2005/06/20 06:22:32 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUROIS.pls
--
--  DESCRIPTION
--
--      Specification of package BOM_RTG_OI_UTIL
--
--  NOTES
--
--  HISTORY
--
--  13-DEC-02   Deepak Jebar    Initial Creation
--  15-JUN-05   Abhishek Bhardwaj Added Batch Id
--
***************************************************************************/

FUNCTION Process_Rtg_header (
    org_id              NUMBER,
    all_org             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
) Return INTEGER;

FUNCTION Process_Op_Seqs (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
) return INTEGER;

FUNCTION Process_Op_Resources  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
) return INTEGER;

FUNCTION Process_Sub_Op_Resources  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
) return INTEGER;

FUNCTION Process_Op_Nwks  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
   ) return INTEGER;

FUNCTION Process_Rtg_Revisions (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
) return INTEGER;
END BOM_RTG_OI_UTIL;

 

/
