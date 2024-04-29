--------------------------------------------------------
--  DDL for Package Body POR_CS_UOM_CONVERSION_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_CS_UOM_CONVERSION_S" as
/* $Header: ICXCDXUB.pls 115.1 2003/01/21 20:26:53 sbgeorge noship $*/

procedure get_oracle_uom(p_requisite_uom in varchar2,
                         p_oracle_uom    out NOCOPY varchar2) is
  l_return_status varchar2(30);
  l_msg_count number;
  l_msg_data varchar2(240);
  l_oracle_uom varchar(80);
begin

  ec_code_conversion_pvt.convert_from_ext_to_int(
    p_api_version_number=>'1.0',
    p_return_status=>l_return_status,
    p_msg_count=>l_msg_count,
    p_msg_data=>l_msg_data,
    p_category=>'UOM',
    p_key1=>'REQUISITE',
    p_ext_val1=>p_requisite_uom,
    p_int_val=>p_oracle_uom);

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    p_oracle_uom := p_requisite_uom;
  end if;

exception
  when others then
    p_oracle_uom := p_requisite_uom;
end get_oracle_uom;

procedure get_applsys_schema(p_schema out NOCOPY varchar2) is
l_install boolean;
l_out_status varchar2(2000);
l_out_industry varchar2(2000);
l_out_schema varchar2(2000);
begin
  l_install := fnd_installation.get_app_info('FND', l_out_status,
               l_out_industry, l_out_schema);
  p_schema := l_out_schema;
exception
  when others then
    null;
end get_applsys_schema;

end por_cs_uom_conversion_s;

/
