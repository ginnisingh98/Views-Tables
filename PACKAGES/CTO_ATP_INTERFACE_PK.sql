--------------------------------------------------------
--  DDL for Package CTO_ATP_INTERFACE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_ATP_INTERFACE_PK" AUTHID CURRENT_USER AS
/* $Header: CTOATPIS.pls 115.9 2002/11/19 18:53:53 ssheth ship $ */

/* flag to indicate valid line in a ship set */
TYPE FLAG_TBL_TYPE is table of boolean index by binary_integer ;

PROCEDURE Create_Atp_Bom(p_atp_bom     in out NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
			x_return_status  out varchar2,
			x_msg_data       out varchar2,
			x_msg_count      out number);

PROCEDURE Extend_Atp_Bom(p_atp_bom  IN OUT NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
			x_return_status  out varchar2,
			x_msg_data       out varchar2,
			x_msg_count      out number);

PROCEDURE Populate_Mandatory_components(p_atp_bom IN OUT NOCOPY MRP_ATP_PUB.atp_bom_rec_typ,
				p_index		  IN  Number,
				X_return_status   OUT Varchar2,
				X_Msg_count       OUT Number,
				X_Msg_Data        OUT Varchar2);

procedure get_atp_bom(
  p_shipset       in out NOCOPY  MRP_ATP_PUB.ATP_REC_TYP
, p_atp_bom_rec      out NOCOPY  MRP_ATP_PUB.ATP_BOM_REC_TYP
, x_return_status    out         varchar2
, x_msg_count        out         number
, x_msg_data         out         varchar2
);


PROCEDURE get_model_sourcing_org(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists out varchar2
, p_sourcing_org         out NUMBER
, p_source_type          out NUMBER
, p_transit_lead_time    out NUMBER
, x_return_status             out varchar2
, p_line_id              in number default null
, p_ship_set_name        in varchar2 default null
) ;



PROCEDURE CREATE_CTO_MODEL_DEMAND (
                             p_shipset       IN OUT NOCOPY MRP_ATP_PUB.ATP_REC_TYP,
                             p_session_id       IN  number,
                             p_shipset_status   IN  MRP_ATP_PUB.SHIPSET_STATUS_REC_TYPE,
                             xreturn_status     OUT varchar2,
                             xmsgcount          OUT number,
                             xmsgdata           OUT varchar2);

PROCEDURE CREATE_CTO_ITEM_DEMAND(x_return_status out varchar2,
                             x_msg_count     out number,
                             x_msg_data      out varchar2);



G_OE_VALIDATION_ORG  Number;
END CTO_ATP_INTERFACE_PK ;

 

/
