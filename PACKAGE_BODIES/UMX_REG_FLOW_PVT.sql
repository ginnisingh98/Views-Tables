--------------------------------------------------------
--  DDL for Package Body UMX_REG_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REG_FLOW_PVT" as
/* $Header: UMXPRFWB.pls 120.2 2005/07/02 04:24:13 appldev noship $ */
-- Start of Comments
-- Package name     : UMX_REG_FLOW_PVT
-- Purpose          : generate password and send email to user with the password.
-- History          :

-- KCHERVEL  12/03/01  Created
-- NOTE             :
-- End of Comments
---------------------------------------------------------------------------
/* returns a delimited string of the Html parameters. Returns null if no parameters are passed */
function getDelimitedHtmlParams(htmlParams in paramsTabType) return varchar2 is
i pls_integer;
begin
  i := htmlParams.FIRST;
  if i is null then
    return null;
  end if;

  jtf_dbstream_utils.clearOutputStream;
  jtf_dbstream_utils.writeInt(htmlParams.count);
  while i is not null loop
    jtf_dbstream_utils.writeString(htmlParams(i).paramName);
    jtf_dbstream_utils.writeString(htmlParams(i).paramValue);
    i := htmlParams.next(i);
  end loop;
  return jtf_dbstream_utils.getOutputStream;
end getDelimitedHtmlParams;
-----------------------------------------------------------------------------
/* returns an encrypted delimited string of the regSrv and the reg parameters
*/
function getDelimRegParams(regSrv in varchar2, regParams in paramsTabType) return varchar2 is
i pls_integer;
begin
  jtf_dbstream_utils.clearOutputStream;
  jtf_dbstream_utils.writeInt(regParams.count + 1);
   -- add regSrv to the String
  jtf_dbstream_utils.writeString('reg_service_code');
  jtf_dbstream_utils.writeString(regSrv);
  i := regParams.FIRST;
  while i is not null loop
    jtf_dbstream_utils.writeString(regParams(i).paramName);
    jtf_dbstream_utils.writeString(regParams(i).paramValue);
    i := regParams.next(i);
  end loop;
  return jtf_dbstream_utils.getOutputStream;
end getDelimRegParams;

----------------------------------------------------------------------------
function validate_reg_service_code(p_regSrv in varchar2) return boolean is
CURSOR isRegSrvValid IS
 select UMX.reg_service_type, UMX.reg_function_id, UMX.end_date, f.function_id
 from umx_reg_services_b umx, fnd_form_functions f
 where UMX.reg_service_code = p_regSrv
 and UMX.reg_function_id = f.function_id(+);
begin
  if p_regSrv is null then
    raise_application_error(-20001, FND_MESSAGE.get_string('FND', 'UMX_GENURL_REGSRV_PARAM_NULL'));
  end if;

  for i in isRegSrvValid loop
    if (i.reg_service_type <> 'SELF_SERVICE') then
      raise_application_error(-20001, fnd_message.get_string('FND','UMX_GENURL_REGSRV_INVALID_TYPE'));
    elsif (i.reg_function_id is null) then
      raise_application_error(-20001, fnd_message.get_string('FND','UMX_GENURL_REGFUNC_NULL1'));
   elsif (nvl(i.end_date, sysdate) < sysdate) then
      raise_application_error(-20001, fnd_message.get_string('FND','UMX_GENURL_REGSRV_ENDDATED'));
    elsif (i.function_id is null) then
      /*FND_MESSAGE.SET_NAME('FND', 'UMX_GENURL_REGFUNC_INVALID');
      FND_MESSAGE.SET_TOKEN('REG_SRV_CODE', p_regSrv, FALSE);
      FND_MSG_PUB.ADD;
      */
      raise_application_error(-20001, fnd_message.get_string('FND','UMX_GENURL_REGFUNC_INVALID'));
     end if;
    end loop;
  return true;
end;

-------------------------------------------------------------------------------

/**
 * this API is the body of icx_portlet.createExecLink
 * it is rewritten to avoid calls to icx_portlet -- bug 2959905
 */

function createExecLink(p_application_id         number,
                          p_responsibility_id      number,
                          p_security_group_id      number,
                          p_function_id            number,
                          p_parameters             VARCHAR2,
                          p_target                 VARCHAR2,
                          p_link_name              VARCHAR2,
                          p_url_only               VARCHAR2)
         return varchar2 is

l_RFLink       varchar2(4000);

begin

if p_url_only = 'N'
then
  l_RFLink := FND_RUN_FUNCTION.GET_RUN_FUNCTION_LINK
              (P_TEXT =>p_link_name,
               P_TARGET => p_target,
               P_FUNCTION_ID => p_function_id,
               P_RESP_APPL_ID => p_application_id,
               P_RESP_ID => p_responsibility_id,
               P_SECURITY_GROUP_ID => p_security_group_id,
               P_PARAMETERS => p_parameters);
else
  l_RFLink := FND_RUN_FUNCTION.GET_RUN_FUNCTION_URL
              (P_FUNCTION_ID => p_function_id,
               P_RESP_APPL_ID => p_application_id,
               P_RESP_ID => p_responsibility_id,
               P_SECURITY_GROUP_ID => p_security_group_id,
               P_PARAMETERS => p_parameters);
end if;

return l_RFlink;

end createExecLink;


--------------------------------------------------------------------------
/* wrapper on createExecLink with app as FND, resp as -1 */
function  generateURL (p_function_name in varchar2,
                  p_parameters    in varchar2,
                  p_target           in varchar2,
                  p_url_only         in varchar2 := 'Y' ,
                  p_linkName in varchar2 := null)  return varchar2 is
l_application_id number;
l_function_id    number;
begin
   begin
      SELECT application_id
      INTO l_application_id
      FROM fnd_application
      WHERE application_short_name = 'FND';

      SELECT function_id
      INTO l_function_id
      FROM fnd_form_functions
      WHERE function_name = 'UMX_FLOW_LAUNCHER';
  exception
    when others then
      return -1;
  end;

 return  createExecLink(p_application_id =>null,
                          p_responsibility_id      => null,
                          p_security_group_id      => null,
                          p_function_id            => l_function_id,
                          p_parameters             => p_parameters,
                          p_target                 => p_target,
                          p_link_name              => p_linkName,
                          p_url_only               => p_url_only);
end;
---------------------------------------------------------------------------
function  generateRegistrationURL (p_delimHtmlParams  in varchar2,
                                   p_delimRegParams   in varchar2,
                                   p_target           in varchar2,
                                   p_url_only         in varchar2 := 'Y' ,
                                   p_linkName in varchar2 := null)  return varchar2 is
l_parameters varchar2(4000);
l_application_id number;
l_function_id    number;
begin
  -- added a 1 before the encrypted parameters, otherwise pageContext.getParams
  -- will return null
  if p_delimHtmlParams is not null then
    l_parameters := 'UMXHtmlParams='||p_delimHtmlParams
                  ||'&'||'UMXRegParams=1'||icx_call.encrypt(p_delimRegParams);
  else
    l_parameters := 'UMXRegParams=1'||icx_call.encrypt(p_delimRegParams);
  end if;

  begin
      SELECT application_id
      INTO l_application_id
      FROM fnd_application
      WHERE application_short_name = 'FND';

      SELECT function_id
      INTO l_function_id
      FROM fnd_form_functions
      WHERE function_name = 'UMX_FLOW_LAUNCHER';
  exception
    when others then
      return -1;
  end;

 return  createExecLink(p_application_id => null,
                          p_responsibility_id      => null,
                          p_security_group_id      => null,
                          p_function_id            => l_function_id,
                          p_parameters             => l_parameters,
                          p_target                 => p_target,
                          p_link_name              => p_linkName,
                          p_url_only               => p_url_only);
 /*
  return icx_portlet.createExecLink2(
                           p_application_short_name => 'FND',
                           p_responsibility_key     => 'UMX_ANONYMOUS_USER' ,
                           p_security_group_key     => '',
                           p_function_name          => 'UMX_FLOW_LAUNCHER' ,
                           p_parameters             => l_parameters,
                           p_target                 => p_target,
                           p_link_name              => p_linkName,
                           p_url_only               => p_url_only) ;

 return icx_portlet.createExecLink2(
                           p_application_short_name => 'JTF',
                           p_responsibility_key     =>'JTA_UMX_ANONYMOUS_USER',
                           p_security_group_key     => '',
                           p_function_name          => 'JTA_UMX_FORGOT_PWD' ,
                           p_parameters             => l_parameters,
                           p_target                 => p_target,
                           p_link_name              => p_linkName,
                           p_url_only               => p_url_only) ;
*/

end;
---------------------------------------------------------------------------
/* see spec for description */
function  generateRegistrationURL (p_regSrv      in varchar2,
                                   p_htmlParams  in paramsTabType := default_paramtab,
                                   p_regParams   in paramsTabType := default_paramtab,
                                   p_target      in varchar2,
                                   p_url_only  in varchar2 := 'Y' ,
                                   p_linkName in varchar2 := null)  return varchar2 is
l_delimHtmlParams varchar2(4000);
l_delimRegParams  varchar2(4000);
--l_parameters    varchar2(4000);
begin
/*  if p_regSrv is null then
   -- raise exception
    FND_MESSAGE.SET_NAME('FND', 'UMX_REQUIRED_FIELD');
    FND_MESSAGE.SET_TOKEN('PROCEDURE', 'UMX_REG_FLOW_PVT.generateRegistrationURL', FALSE);
    FND_MESSAGE.SET_TOKEN('FIELD', 'Registration Service', FALSE);
    FND_MSG_PUB.ADD;
    app_exception.raise_exception;
  end if;
*/
  if validate_reg_service_code(p_regSrv) then
   l_delimHtmlParams := getDelimitedHtmlParams(p_htmlParams);
   l_delimRegParams  := getDelimRegParams(p_regSrv, p_regParams);
   return generateRegistrationURL (p_delimHtmlParams  => l_delimHtmlParams,
                           p_delimRegParams   => l_delimRegParams,
                           p_target           => p_target,
                           p_url_only         => p_url_only,
                           p_linkName         => p_linkname);
 end if;
end;
--------------------------------------------------------------------------
procedure getDelimitedString(p_string in varchar2,
                  x_delimitedString out NOCOPY varchar2) is
begin
  if substr(p_string,0,14) = 'UMX_NO_ENCRYPT' then
     x_delimitedString := substr(p_string,15);
  else
     x_delimitedString := icx_call.decrypt(substr(p_string,2));
  end if;
end;
---------------------------------------------------------------------------
function  genRegistrationURL (p_regSrv      in varchar2,
                                   p_target      in varchar2,
                                   p_url_only  in varchar2 := 'Y' ,
                                   p_linkName in varchar2 := null)  return varchar2 is
begin
   return generateRegistrationURL (p_regSrv      => p_regSrv,
                                   p_htmlParams  => default_paramtab,
                                   p_regParams   => default_paramtab,
                                   p_target      => p_target,
                                   p_url_only    => p_url_only ,
                                   p_linkName    => p_linkname);
end;


---------------------------------------------------------------------------
function  generateRegistrationURL (p_regSrv           in varchar2,
                                   p_delimHtmlParams  in varchar2,
                                   p_delimRegParams   in varchar2,
                                   p_target           in varchar2,
                                   p_url_only         in varchar2 := 'Y' ,
                                   p_linkName in varchar2 := null)  return varchar2 is
begin
   if (validate_reg_service_code(p_regSrv)) then
     return generateRegistrationURL (p_delimHtmlParams => p_delimHtmlParams,
                                   p_delimRegParams  => p_delimRegParams,
                                   p_target   => p_target        ,
                                   p_url_only  => p_url_only        ,
                                   p_linkName => p_linkName);
   end if;
end;


End UMX_REG_FLOW_PVT;

/
