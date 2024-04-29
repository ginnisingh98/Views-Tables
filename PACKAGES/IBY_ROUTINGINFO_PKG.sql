--------------------------------------------------------
--  DDL for Package IBY_ROUTINGINFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ROUTINGINFO_PKG" AUTHID CURRENT_USER as
/*$Header: ibyrouts.pls 115.14 2002/05/21 22:48:45 pkm ship     $*/

type  t_rulesRec is record(
  ruleId		NUMBER(15),
  ruleName		VARCHAR2(80),
  bepInstrType		VARCHAR2(30),
  priority		NUMBER(15),
  bepId			NUMBER(15),
  bepSuffix		VARCHAR2(10),
  activeStatus		NUMBER(2),
  payeeId		VARCHAR2(80),
  merchantAccount       VARCHAR2(80),
  hitCounter            NUMBER(15),
  object_version 	NUMBER
);
type  t_condtRec is record (
  ruleName		VARCHAR2(80),
  ruleId		NUMBER(15),
  condition_name        VARCHAR2(80),
  parameter		VARCHAR2(30),
  operation		VARCHAR2(30),
  value			VARCHAR2(30),
  is_value_string 	VARCHAR2(1),
  entry_seq		NUMBER(4),
  object_version 	NUMBER
);

type t_condtRecVec is table of t_condtRec index by binary_integer;

/*-------------------------------------------------------------------+
|  Function: createRoutingInfo.                                      |
|  Purpose:  To create a Routing information in the database.        |
+-------------------------------------------------------------------*/
procedure createRoutingInfo(i_rules in t_rulesRec,
                            i_conditions in t_condtRecVec);

/*
** Function: modifyRoutingInfo.
** Purpose:  modifies the Routing information in the database.
*/
procedure modifyRoutingInfo(i_rules in t_rulesRec,
                            i_conditions in t_condtRecVec);

/*
** Function: deleteRoutingInfo.
** Purpose:  deletes the Routing information in the database.
*/
procedure deleteRoutingInfo ( i_paymentmethodId in
                                   iby_routinginfo.paymentmethodId%type,
                              i_paymentmethodName in
                                   iby_routinginfo.paymentmethodName%type,
                              i_version in
                                   iby_routinginfo.object_version_number%type);

/*
** Function: isDuplicateCondNames.
** Purpose:  Checks whether the input rule condition names contain
**           duplicates. Returns 'true' if there are duplicates, and
**           'false' if not.
*/
function isDuplicateCondNames ( i_conditions in t_condtRecVec )
         RETURN BOOLEAN;

end iby_routinginfo_pkg;

 

/
