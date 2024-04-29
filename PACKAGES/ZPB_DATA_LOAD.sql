--------------------------------------------------------
--  DDL for Package ZPB_DATA_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DATA_LOAD" AUTHID CURRENT_USER AS
/* $Header: zpbdataload.pls 120.0.12010.2 2005/12/23 07:19:22 appldev noship $ */

PROCEDURE RUN_DATA_LOAD(p_task_id IN NUMBER,
                        p_dataAW  in Varchar2,
                        p_codeAW  in Varchar2,
                        p_annotAW in Varchar2);
END ZPB_DATA_LOAD;

 

/
