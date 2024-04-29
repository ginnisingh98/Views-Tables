--------------------------------------------------------
--  DDL for Package CZ_BOM_CONFIG_EXPLOSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_BOM_CONFIG_EXPLOSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: BOMCZCBS.pls 115.9 2003/12/24 00:29:48 ssawant ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
		       X_Bill_Sequence_Id		NUMBER := NULL,
                       X_Top_Bill_Sequence_Id           NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Effectivity_Date               DATE,
                       X_Sort_Order                     VARCHAR2,
                       X_Select_Flag                    VARCHAR2,
                       X_Select_Quantity                NUMBER,
                       X_Session_Id                     NUMBER,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
                      );


  PROCEDURE BOM_INS_MODEL_AND_MANDATORY(p_group_id IN NUMBER,
                                        p_bill_sequence_id IN NUMBER,
                                        p_top_bill_sequence_id IN NUMBER,
                                        p_top_predefined_item_id IN NUMBER,
                                        p_validation_org_id  IN NUMBER,
                                        p_current_org_id  IN NUMBER,
                                        p_cz_config_hdr_id      IN NUMBER,
                                        p_cz_config_rev_num     IN NUMBER,
                                        x_top_ato_line_id  OUT NOCOPY NUMBER,
                                        x_top_matched_item_id  OUT NOCOPY NUMBER,
                                        x_match_profile_on  OUT NOCOPY VARCHAR2,
                                        x_match_found       OUT NOCOPY VARCHAR2,
                                        x_message  IN OUT NOCOPY VARCHAR2);

  procedure create_preconfig_item_ml(
     p_use_matched_item     in varchar2,
     p_match_profile_on     in varchar2,
     p_top_predefined_item_id      in number,
     p_top_matched_item_id      in number,
     p_top_ato_line_id       in  bom_cto_order_lines.ato_line_id%type,
     p_current_org_id        in number ,
     x_bill_sequence_id      out NOCOPY number,
     x_mlmo_item_created     out NOCOPY varchar2,
     x_routing_exists        out NOCOPY varchar2,
     x_return_status         out NOCOPY varchar2,
     x_msg_count             out NOCOPY number,
     x_msg_data              out NOCOPY varchar2

  ) ;


  /* Patchset J signature */
  procedure create_preconfig_item_ml(
     p_use_matched_item     in varchar2,
     p_match_profile_on     in varchar2,
     p_top_predefined_item_id      in number,
     p_top_matched_item_id      in number,
     p_top_ato_line_id       in  bom_cto_order_lines.ato_line_id%type,
     p_current_org_id        in number ,
     x_bill_sequence_id      out NOCOPY number,
     x_mlmo_item_created     out NOCOPY varchar2,
     x_routing_exists        out NOCOPY varchar2,
     x_return_status         out NOCOPY varchar2,
     x_msg_count             out NOCOPY number,
     x_msg_data              out NOCOPY varchar2,
     x_t_dropped_items       out NOCOPY CTO_CONFIG_BOM_PK.t_dropped_item_type
  ) ;


/*
 old declaration reintroduced by Sushant on 19-Aug-2002
*/
  PROCEDURE BOM_INS_MODEL_AND_MANDATORY(x_group_id IN NUMBER,
                                        x_bill_sequence_id IN NUMBER,
                                        x_top_bill_sequence_id IN NUMBER,
                                        x_cz_config_hdr_id      IN NUMBER,
                                        x_cz_config_rev_num     IN NUMBER,
                                        x_message  IN OUT NOCOPY VARCHAR2);


END CZ_BOM_CONFIG_EXPLOSIONS_PKG;

 

/
