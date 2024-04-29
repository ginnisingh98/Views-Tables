--------------------------------------------------------
--  DDL for Package MSC_ATP_CTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_CTO" AUTHID CURRENT_USER AS
/* $Header: MSCCTOPS.pls 120.3 2007/12/12 10:24:35 sbnaik ship $  */


TYPE mand_comp_info_rec is RECORD (
     sr_inventory_item_id   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     quantity                  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     atp_flag               MRP_ATP_PUB.char1_arr := MRP_ATP_PUB.char1_arr(),
     atp_components_flag    MRP_ATP_PUB.char1_arr := MRP_ATP_PUB.char1_arr(),
     atf_date               MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),-- For time_phased_atp
     bom_item_type          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     fixed_lead_time        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     variable_lead_time     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     dest_inventory_item_id  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     uom_code               MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
     --4570421
     scaling_type                  MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
     scale_multiple                MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
     scale_rounding_variance       MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
     rounding_direction            MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
     component_yield_factor        MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(), --4570421
     usage_qty                     MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(), --4775920
     organization_type             MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr()  --4775920
     );

TYPE Item_Sourcing_Info_Rec is RECORD (
     sr_inventory_item_id   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     line_id                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     ato_line_id            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     match_item_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr());

G_MODEL_QUNATITY  NUMBER;
G_MODEL_IS_PRESENT NUMBER := 2;
G_MODEL_IS_PRESENT_IN_SET NUMBER := 2;
G_INCLUDED_ITEM_IS_PRESENT NUMBER := 2;

G_MODEL_BOM_IS_COLLECTED  NUMBER := 2;

SUCCESS CONSTANT NUMBER := 1;
FAIL CONSTANT NUMBER := 2;



PROCEDURE Check_Lines_For_CTO_ATP (
  p_atp_rec             IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
  p_session_id          IN   number,
  p_dblink              IN   varchar2,
  p_instance_id         IN   number,
  x_return_status       OUT  NoCopy VARCHAR2
);

Procedure Match_CTO_Lines(P_session_id IN Number,
                          p_dblink  IN VARCHAR2,
                          p_instance_id IN number,
                          x_return_status OUT NOCOPY VARCHAR2);

Procedure Process_CTO_Sources(p_dblink IN varchar2,
                              p_session_id  IN number,
                              p_cto_sources CTO_OSS_SOURCE_PK.OSS_ORGS_LIST_REC_TYPE,
                              p_instance_id IN NUMBER);

Procedure Get_Mandatory_Components(p_plan_id              IN NUMBER,
                                   p_instance_id          IN NUMBER,
                                   p_organization_id      IN NUMBER,
                                   p_sr_inventory_item_id IN NUMBER,
                                   p_quantity             IN NUMBER,
                                   p_request_date         IN DATE,
                                   p_dest_inv_item_id     IN NUMBER,
                                   x_mand_comp_info_rec   OUT NOCOPY MSC_ATP_CTO.mand_comp_info_rec
                                   );


Procedure Validate_CTO_Sources (P_SOURCE_LIST   IN OUT NOCOPY MRP_ATP_PVT.Atp_Source_Typ,
                                p_line_ids      IN MRP_ATP_PUB.number_arr,
                                p_instance_id   IN number,
                                p_session_id    IN number,
                                x_return_status OUT NOCOPY varchar2);

Procedure Extend_Sources_Rec(P_Source_Rec IN OUT  NOCOPY MRP_ATP_PVT.Atp_Source_Typ);

procedure Populate_Cto_Bom(p_session_id IN number,
                           p_refresh_number IN number,
                           p_dblink     IN varchar2);

Procedure Get_CTO_BOM(p_session_id      IN NUMBER,
                      p_comp_rec        OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ,
                      p_line_id         IN NUMBER,
                      p_request_date    IN DATE,
                      p_request_quantity  IN NUMBER,
                      p_parent_so_quantity IN NUMBER,
                      p_inventory_item_id IN NUMBER,
                      p_organization_id IN NUMBER,
                      p_plan_id         IN NUMBER,
                      p_instance_id     IN NUMBER,
                      p_fixed_lt        IN NUMBER,
                      p_variable_lt     IN NUMBER);

Procedure Maintain_OS_Sourcing(p_instance_id IN Number,
                               p_atp_rec     IN MRP_ATP_PUB.atp_rec_typ,
                               p_status    IN Number);


PROCEDURE Check_Base_Model_For_Cap_Check(p_config_inventory_item_id       IN  NUMBER,
                                              p_base_model_id             IN  NUMBER,
                                              p_request_date              IN  DATE,
                                              p_instance_id               IN  NUMBER,
                                              p_plan_id                   IN  NUMBER,
                                              p_organization_id           IN  NUMBER,
                                              p_quantity                  IN  NUMBER,
                                              x_model_sr_inv_id           OUT NOCOPY NUMBER,
                                              x_check_model_capacity_flag OUT NOCOPY NUMBER);

END MSC_ATP_CTO;




/
