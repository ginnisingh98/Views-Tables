--------------------------------------------------------
--  DDL for Package POR_CS_UOM_CONVERSION_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_CS_UOM_CONVERSION_S" AUTHID CURRENT_USER as
/* $Header: ICXCDXUS.pls 115.1 2003/01/21 20:26:05 sbgeorge noship $*/

procedure get_oracle_uom(p_requisite_uom in varchar2,
                         p_oracle_uom    out NOCOPY varchar2);
procedure get_applsys_schema(p_schema out NOCOPY varchar2);

end por_cs_uom_conversion_s;

 

/
