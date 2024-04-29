--------------------------------------------------------
--  DDL for Package IGS_SC_GRANTS_TBL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SC_GRANTS_TBL_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSSC04S.pls 115.0 2003/12/05 17:50:19 atereshe noship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Arkadi Tereshenkov

 Date Created By    : Oct-01-2002

 Purpose            : This is a package used for a grant model for each object

 remarks            :

 Change History

Who                   When           What
-----------------------------------------------------------
Arkadi Tereshenkov    Apr-10-2002    New Package created.

******************************************************************/

FUNCTION insert_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION select_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION update_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION delete_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2;


END IGS_SC_GRANTS_TBL_PVT;

 

/
