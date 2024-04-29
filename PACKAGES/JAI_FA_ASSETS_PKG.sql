--------------------------------------------------------
--  DDL for Package JAI_FA_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_FA_ASSETS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_fa_ast.pls 120.1 2005/07/20 12:57:49 avallabh ship $ */

procedure mass_additions
(
errbuf               out NOCOPY varchar2,
retcode              out NOCOPY varchar2,
p_parent_request_id           in  number
);

procedure claim_excise_on_retirement(
   retcode                out nocopy  varchar2,
   errbuf                 out nocopy  varchar2,
   p_organization_id                  number,
   p_location_id                      number,
   p_receipt_num                      varchar2,
   p_shipment_line_id                 number,
   p_booktype_id                      varchar2,
   p_asset_id                         number
 );

function get_date_place_in_service
( p_asset_id in number )
return varchar2;

END jai_fa_assets_pkg;
 

/
