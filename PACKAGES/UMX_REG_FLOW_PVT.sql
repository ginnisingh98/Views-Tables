--------------------------------------------------------
--  DDL for Package UMX_REG_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_REG_FLOW_PVT" AUTHID CURRENT_USER as
/* $Header: UMXPRFWS.pls 115.1 2004/08/09 22:20:54 kchervel noship $ */
-- Start of Comments
-- Package name     : UMX_REG_FLOW_PVT
-- Purpose          : generate URL
-- History          :

-- KCHERVEL  12/03/01  Created
-- NOTE             :
-- End of Comments

/** record type for holding name , value pairs
 */
type paramsRecType is record
  (
     paramName               wf_item_attributes.name%TYPE := null,
     paramValue              wf_item_attributes.text_Default%TYPE := null
  );

type paramsTabType is table of paramsRecType
    index by binary_integer;

Default_paramTab paramsTabType;

/**
    *
    *  @param regSrv indicates the registration service for which the registration request is being made
    *  @param htmlParams  parameters required to be passed through the URL for rendering the page. These parameters are not added to regBean.
    *  @param regParams   registration parameters. These parameters are serialized and encrypted before passing them to the createExecLink. These are the only parameters added to RegBean.
    *  @param target   target page. This is the page to forward to once the registration is complete. The target parameter is passed to page 3 discussed above. It is not encrypted and will not be automatically added to the RegBean.
    * Teams should keep track of this parameter and forward to this page once registration is complete.
    *  @param URLOnly if not 'Y' returns a href link to run the function
    *  @param linkName name of the link if a href link is generated
    *
    *  @return URL for running the user registration page with all parameters encrypted
    *
 * This method uses

 JTF_DBSTREAM_UTILS.writeString(s) to serialize the name, value pairs
ICX_PORTLET.createExecLink() to generate the required URL passing the delimited string as a parameter UMXRegParams
 */
function  generateRegistrationURL (p_regSrv      in varchar2,
                                   p_htmlParams  in paramsTabType := default_paramtab,
                                   p_regParams   in paramsTabType := default_paramtab,
                                   p_target      in varchar2,
                                   p_url_only  in varchar2 := 'Y' ,
                                   p_linkName in varchar2 := null)  return varchar2;

function  generateRegistrationURL (p_regSrv           in varchar2,
                                   p_delimHtmlParams  in varchar2,
                                   p_delimRegParams   in varchar2,
                                   p_target           in varchar2,
                                   p_url_only         in varchar2 := 'Y' ,
                                   p_linkName in varchar2 := null)  return varchar2;

procedure getDelimitedString(p_string in varchar2,
                             x_delimitedString out NOCOPY varchar2);
function  genRegistrationURL (p_regSrv      in varchar2,
                              p_target      in varchar2,
                              p_url_only  in varchar2 := 'Y' ,
                              p_linkName in varchar2 := null)  return varchar2;
/* wrapper on createExecLink with app as FND, resp as -1 */
function  generateURL (p_function_name in varchar2,
                  p_parameters    in varchar2,
                  p_target           in varchar2,
                  p_url_only         in varchar2 := 'Y' ,
                  p_linkName in varchar2 := null)  return varchar2;
End UMX_REG_FLOW_PVT;

 

/
