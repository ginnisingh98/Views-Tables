--------------------------------------------------------
--  DDL for Package Body GMO_LABEL_MGMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_LABEL_MGMT" AS
/* $Header: GMOLBLPB.pls 120.1 2005/09/16 08:47:04 skarimis noship $ */


FUNCTION AUTO_PRINT_ENABLED return boolean Is
L_VALUE VARCHAR2(32);
BEGIN

FND_PROFILE.GET(NAME=>'GMO_LABEL_PRINT_MODE',VAL=>L_VALUE);
if l_value ='AUTOMATIC' then
 return TRUE;
else
 return false;
end if;
END;

end GMO_LABEL_MGMT;

/
