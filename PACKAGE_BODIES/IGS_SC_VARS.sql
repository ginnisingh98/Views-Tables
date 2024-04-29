--------------------------------------------------------
--  DDL for Package Body IGS_SC_VARS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SC_VARS" AS
/* $Header: IGSSC03B.pls 115.0 2003/12/05 17:50:41 atereshe noship $ */

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
) RETURN VARCHAR2
IS
  CURSOR c_attr_value IS
    SELECT attr_value
      FROM igs_sc_usr_att_vals
     WHERE user_attrib_id = p_attrib_id
           AND user_id = get_userid;

  l_attr_value igs_sc_usr_att_vals.attr_value%TYPE;

BEGIN

  OPEN c_attr_value;
 FETCH c_attr_value INTO l_attr_value;
 CLOSE c_attr_value;

 RETURN l_attr_value;

END get_att;



FUNCTION get_userid
RETURN NUMBER
IS
BEGIN

 RETURN FND_GLOBAL.user_id;

END get_userid;


FUNCTION get_partyid
RETURN NUMBER
IS
BEGIN

 RETURN get_att(1);

END get_partyid;



END IGS_SC_VARS;

/
