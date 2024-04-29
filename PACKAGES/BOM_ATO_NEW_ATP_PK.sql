--------------------------------------------------------
--  DDL for Package BOM_ATO_NEW_ATP_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_ATO_NEW_ATP_PK" AUTHID CURRENT_USER as
/* $Header: BOMNATPS.pls 115.0 99/08/18 12:50:15 porting shi $ */

gErrorMessage   varchar2(250);
gMessageName    varchar2(80) ;
gTableName      varchar2(80) ;
gUserID         number       ;
gLoginId        number       ;


function config_link_atp(
          RTOMLine      in number,
          dSrcHdrId    in number,
          dSrctype     in number,
          OrgId        in number,
          error_message out varchar2,
          message_name  out varchar2)

return integer;

function config_delink_atp(
          RTOMLine      in number,
          dSrcHdrId    in number,
          dSrctype     in number,
          OrgId        in number,
          error_message out varchar2,
          message_name  out varchar2)
return integer;

end BOM_ATO_NEW_ATP_PK;

 

/
