--------------------------------------------------------
--  DDL for Package MSC_ORG_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ORG_SECURITY" AUTHID CURRENT_USER AS
/* $Header: MSCORGSS.pls 120.1 2005/06/17 13:17:53 appldev  $  */
PROCEDURE set_org_security(
                      p_selected_orgs      IN  varchar2
                     ,p_resp_id            IN  varchar2
);

procedure get_resp_id   (
                      p_resp               IN  varchar2
                     ,p_resp_id            OUT NoCopy varchar2);

procedure insert_row (p_organization_id in number,
                      p_sr_instance_id  in number,
                      p_responsibility_id in number,
                      p_resp_appl_id in number,
                      p_eff_from_date in date,
                      p_eff_to_date in date);
procedure update_row (p_organization_id in number,
                      p_sr_instance_id  in number,
                      p_responsibility_id in number,
                      p_resp_appl_id in number,
                      p_eff_from_date in date,
                      p_eff_to_date in date,
                      p_action varchar2);

END msc_org_security;

 

/
