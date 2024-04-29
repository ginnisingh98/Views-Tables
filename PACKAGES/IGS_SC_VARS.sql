--------------------------------------------------------
--  DDL for Package IGS_SC_VARS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SC_VARS" AUTHID CURRENT_USER AS
/* $Header: IGSSC03S.pls 115.0 2003/12/05 17:50:12 atereshe noship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Arkadi Tereshenkov

 Date Created By    : Oct-01-2002

 Purpose            : Grant variables package

 remarks            : None

 Change History

Who                   When           What
-----------------------------------------------------------
Arkadi Tereshenkov    Apr-10-2002    New Package created.

******************************************************************/

FUNCTION get_att (
  p_attrib_id NUMBER
) RETURN VARCHAR2 ;

PRAGMA RESTRICT_REFERENCES(get_att,WNDS);


FUNCTION get_userid RETURN NUMBER;
FUNCTION get_partyid RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(get_userid,WNDS);


END IGS_SC_VARS;

 

/
