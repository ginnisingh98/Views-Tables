--------------------------------------------------------
--  DDL for Package OE_OE_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_AVAILABILITY" AUTHID CURRENT_USER AS
/* $Header: OEXFAVAS.pls 120.0.12010000.1 2008/07/25 07:47:50 appldev ship $ */



TYPE source_orgs_rec IS RECORD
         ( org_id number,
           instance_id number,
           ship_method varchar2(30),
           delivery_lead_time number,
           freight_carrier varchar2(30),
           instance_code varchar2(5),
           attribute1 varchar2(100),
           attribute2 varchar2(100),
           attribute3 varchar2(100),
           attribute4 varchar2(100),
           attribute5 varchar2(100),
           attribute6 number,
           attribute7 number,
           attribute8 number,
           attribute9 number,
           attribute10 number,
           attribute11 date,
           attribute12 date,
           attribute13 date,
           attribute14 date,
           attribute15 date
         );

TYPE source_orgs_table IS TABLE OF source_orgs_rec index by binary_integer;

TYPE panda_rec is RECORD
       (
	   p_inventory_item_id      number,
	   p_qty                    number,
	   p_uom                    varchar2(20),
	   p_request_date           date,
	   p_customer_id            number,
	   p_item_identifier_type   varchar2(40),
	   p_agreement_id           number,
	   p_price_list_id          number,
	   p_ship_to_org_id         number,
	   p_invoice_to_org_id      number,
	   p_ship_from_org_id       number,
	   p_pricing_date           date,
	   p_order_type_id          number,
	   p_ordered_item_id        number, -- added this to fix the bug 3661905
	   p_currency               varchar2(20),
	   p_pricing_context        varchar2(30),
	   p_pricing_attribute1     varchar2(240),
	   p_pricing_attribute2     varchar2(240),
	   p_pricing_attribute3     varchar2(240),
	   p_pricing_attribute4     varchar2(240),
	   p_pricing_attribute5     varchar2(240),
	   p_pricing_attribute6     varchar2(240),
	   p_pricing_attribute7     varchar2(240),
	   p_pricing_attribute8     varchar2(240),
	   p_pricing_attribute9     varchar2(240),
	   p_pricing_attribute10    varchar2(240),
	   p_pricing_attribute11    varchar2(240),
	   p_pricing_attribute12    varchar2(240),
	   p_pricing_attribute13    varchar2(240),
	   p_pricing_attribute14    varchar2(240),
	   p_pricing_attribute15    varchar2(240),
	   p_pricing_attribute16    varchar2(240),
	   p_pricing_attribute17    varchar2(240),
	   p_pricing_attribute18    varchar2(240),
	   p_pricing_attribute19    varchar2(240),
	   p_pricing_attribute20    varchar2(240),
	   p_pricing_attribute21    varchar2(240),
	   p_pricing_attribute22    varchar2(240),
	   p_pricing_attribute23    varchar2(240),
	   p_pricing_attribute24    varchar2(240),
	   p_pricing_attribute25    varchar2(240),
	   p_pricing_attribute26    varchar2(240),
	   p_pricing_attribute27    varchar2(240),
	   p_pricing_attribute28    varchar2(240),
	   p_pricing_attribute29    varchar2(240),
	   p_pricing_attribute30    varchar2(240),
	   p_pricing_attribute31    varchar2(240),
	   p_pricing_attribute32    varchar2(240),
	   p_pricing_attribute33    varchar2(240),
	   p_pricing_attribute34    varchar2(240),
	   p_pricing_attribute35    varchar2(240),
	   p_pricing_attribute36    varchar2(240),
	   p_pricing_attribute37    varchar2(240),
	   p_pricing_attribute38    varchar2(240),
	   p_pricing_attribute39    varchar2(240),
	   p_pricing_attribute40    varchar2(240),
	   p_pricing_attribute41    varchar2(240),
	   p_pricing_attribute42    varchar2(240),
	   p_pricing_attribute43    varchar2(240),
	   p_pricing_attribute44    varchar2(240),
	   p_pricing_attribute45    varchar2(240),
	   p_pricing_attribute46    varchar2(240),
	   p_pricing_attribute47    varchar2(240),
	   p_pricing_attribute48    varchar2(240),
	   p_pricing_attribute49    varchar2(240),
	   p_pricing_attribute50    varchar2(240),
	   p_pricing_attribute51    varchar2(240),
	   p_pricing_attribute52    varchar2(240),
	   p_pricing_attribute53    varchar2(240),
	   p_pricing_attribute54    varchar2(240),
	   p_pricing_attribute55    varchar2(240),
	   p_pricing_attribute56    varchar2(240),
	   p_pricing_attribute57    varchar2(240),
	   p_pricing_attribute58    varchar2(240),
	   p_pricing_attribute59    varchar2(240),
	   p_pricing_attribute60    varchar2(240),
	   p_pricing_attribute61    varchar2(240),
	   p_pricing_attribute62    varchar2(240),
	   p_pricing_attribute63    varchar2(240),
	   p_pricing_attribute64    varchar2(240),
	   p_pricing_attribute65    varchar2(240),
	   p_pricing_attribute66    varchar2(240),
	   p_pricing_attribute67    varchar2(240),
	   p_pricing_attribute68    varchar2(240),
	   p_pricing_attribute69    varchar2(240),
	   p_pricing_attribute70    varchar2(240),
	   p_pricing_attribute71    varchar2(240),
	   p_pricing_attribute72    varchar2(240),
	   p_pricing_attribute73    varchar2(240),
	   p_pricing_attribute74    varchar2(240),
	   p_pricing_attribute75    varchar2(240),
	   p_pricing_attribute76    varchar2(240),
	   p_pricing_attribute77    varchar2(240),
	   p_pricing_attribute78    varchar2(240),
	   p_pricing_attribute79    varchar2(240),
	   p_pricing_attribute80    varchar2(240),
	   p_pricing_attribute81    varchar2(240),
	   p_pricing_attribute82    varchar2(240),
	   p_pricing_attribute83    varchar2(240),
	   p_pricing_attribute84    varchar2(240),
	   p_pricing_attribute85    varchar2(240),
	   p_pricing_attribute86    varchar2(240),
	   p_pricing_attribute87    varchar2(240),
	   p_pricing_attribute88    varchar2(240),
	   p_pricing_attribute89    varchar2(240),
	   p_pricing_attribute90    varchar2(240),
	   p_pricing_attribute91    varchar2(240),
	   p_pricing_attribute92    varchar2(240),
	   p_pricing_attribute93    varchar2(240),
	   p_pricing_attribute94    varchar2(240),
	   p_pricing_attribute95    varchar2(240),
	   p_pricing_attribute96    varchar2(240),
	   p_pricing_attribute97    varchar2(240),
	   p_pricing_attribute98    varchar2(240),
	   p_pricing_attribute99    varchar2(240),
	   p_pricing_attribute100   varchar2(240),
	   p_char_attribute1        varchar2(240),
	   p_char_attribute2        varchar2(240),
	   p_char_attribute3        varchar2(240),
	   p_char_attribute4        varchar2(240),
	   p_char_attribute5        varchar2(240),
	   p_char_attribute6        varchar2(240),
	   p_char_attribute7        varchar2(240),
	   p_char_attribute8        varchar2(240),
	   p_char_attribute9        varchar2(240),
	   p_char_attribute10       varchar2(240),
	   p_num_attribute1         number,
	   p_num_attribute2         number,
	   p_num_attribute3         number,
	   p_num_attribute4         number,
	   p_num_attribute5         number,
	   p_num_attribute6         number,
	   p_num_attribute7         number,
	   p_num_attribute8         number,
	   p_num_attribute9         number,
	   p_num_attribute10        number,
           p_date_attribute1        date,
	   p_date_attribute2        date,
	   p_date_attribute3        date,
	   p_date_attribute4        date,
	   p_date_attribute5        date );

TYPE panda_rec_table IS TABLE OF panda_rec index by binary_integer;

g_panda_rec_table panda_rec_table;
Procedure Call_MRP_ATP(
               in_global_orgs  in varchar2,
               in_ship_from_org_id in number,
out_available_qty out nocopy varchar2,

out_ship_from_org_id out nocopy number,

out_available_date out nocopy date,

out_qty_uom out nocopy varchar2,

x_out_message out nocopy varchar2,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

x_error_message out nocopy varchar2

                      );


PROCEDURE  defaulting(
            in_source in varchar2
            ,in_org_id in varchar2
            ,in_item_id in number
            ,in_customer_id in number
            ,in_ship_to_org_id in number
            ,in_bill_to_org_id in number
            ,in_agreement_id in number
            ,in_order_type_id in number
,out_wsh_id out nocopy number

,out_uom out nocopy varchar2

,out_item_type_code out nocopy varchar2

,out_price_list_id out nocopy number

,out_conversion_type out nocopy varchar2

                     );

Procedure Check_Results_from_rec (
           in_global_orgs    in varchar2
          ,p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

,x_error_message out nocopy varchar2

                                  );

Procedure Initialize_mrp_record(
          p_x_atp_rec IN  OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
         ,l_count     IN  NUMBER);

Procedure Query_Qty_Tree(
                         p_org_id            IN NUMBER,
                         p_item_id           IN NUMBER,
                         p_sch_date          IN DATE DEFAULT NULL,
x_on_hand_qty OUT NOCOPY NUMBER,

x_avail_to_reserve OUT NOCOPY NUMBER);



PROCEDURE get_ship_from_org(in_org_id in number,
out_code out nocopy varchar2,

out_name out nocopy varchar2

                           );

PROCEDURE copy_Header_to_request(
              p_request_type_code in varchar2
             ,p_calculate_price_flag in varchar2
             ,px_req_line_tbl   in out nocopy	QP_PREQ_GRP.LINE_TBL_TYPE
              );


PROCEDURE copy_Line_to_request(
              px_req_line_tbl   in out nocopy QP_PREQ_GRP.LINE_TBL_TYPE
             ,p_pricing_event   in    varchar2
             ,p_Request_Type_Code in	varchar2
             ,p_honor_price_flag in VARCHAR2 Default 'Y'
             ,p_line_index in number
		);


PROCEDURE set_pricing_control_record (
             l_Control_Rec  in out nocopy QP_PREQ_GRP.CONTROL_RECORD_TYPE
            ,in_pricing_event in varchar2);



PROCEDURE build_context_for_line(
             p_req_line_tbl_count in number,
             p_price_request_code in varchar2,
             p_item_type_code in varchar2,
             p_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
             p_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE,
             p_line_index in number
            );



PROCEDURE build_context_for_header(
             p_req_line_tbl_count in number,
             p_price_request_code in varchar2,
             p_item_type_code in varchar2,
             p_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
             p_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
            );


PROCEDURE copy_attribs_to_Req(
         p_line_index number
        ,px_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
        ,px_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
        ,p_pricing_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
        ,p_qualifier_contexts_Tbl  QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
                             );
PROCEDURE append_attr_to_TTables(px_req_line_attr_tbl in out nocopy QP_PREQ_GRP.LINE_ATTR_TBL_TYPE);

PROCEDURE  Append_attributes(
           p_header_id number default null
          ,p_Line_id number default null
          ,p_line_index number
          ,px_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
          ,px_Req_qual_tbl in out nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
          ,p_g_line_index in number  );

PROCEDURE Reset_All_Tbls;
procedure Populate_Temp_Table;
PROCEDURE populate_results(
x_line_tbl  out nocopy QP_PREQ_GRP.LINE_TBL_TYPE,
x_line_qual_tbl  out nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE,
x_line_attr_tbl  out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
x_LINE_DETAIL_tbl out nocopy  QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
x_LINE_DETAIL_qual_tbl    out nocopy  QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
x_LINE_DETAIL_attr_tbl   out   nocopy QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
x_related_lines_tbl       out nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE
);

PROCEDURE price_item(
out_req_line_tbl in out nocopy QP_PREQ_GRP.LINE_TBL_TYPE,
out_Req_line_attr_tbl         in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
out_Req_LINE_DETAIL_attr_tbl  in out nocopy  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
out_Req_LINE_DETAIL_tbl        in out nocopy QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
out_Req_related_lines_tbl      in out nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
out_Req_qual_tbl               in out nocopy QP_PREQ_GRP.QUAL_TBL_TYPE,
out_Req_LINE_DETAIL_qual_tbl   in out nocopy QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
out_child_detail_type out nocopy varchar2
                    );

PROCEDURE pass_values_to_backend(
				in_panda_rec_table in panda_rec_table
				 );


PROCEDURE process_pricing_errors(
                in_line_type_code in varchar2,
                in_status_code    in varchar2,
                in_status_text    in varchar2,
                in_ordered_item    in varchar2,
                in_uom    in varchar2,
                in_unit_price    in number,
                in_adjusted_unit_price    in number,
                in_process_code    in varchar2 ,
                in_price_flag    in varchar2,
                in_price_list_id in number,
l_return_status out nocopy varchar2,

l_msg_count out nocopy number,

l_msg_data out nocopy varchar2

                );

Function Get_Rounding_factor(p_list_header_id number) return number;


Function Get_qp_lookup_meaning( in_lookup_code in varchar2,
                                in_lookup_type in varchar2) return varchar2;

PROCEDURE Get_modifier_name( in_list_header_id in number
,out_name out nocopy varchar2

,out_description out nocopy varchar2

,out_end_date out nocopy date

,out_start_date out nocopy date

,out_currency out nocopy varchar2

,out_ask_for_flag out nocopy varchar2

                           );

FUNCTION get_pricing_attribute(
                       in_CONTEXT_NAME in varchar2,
                       in_ATTRIBUTE_NAME in varchar2
                               ) return varchar2;


PROCEDURE get_Price_List_info(
                          p_price_list_id IN  NUMBER,
out_name out nocopy varchar2,

out_end_date out nocopy date,

out_start_date out nocopy date,

out_automatic_flag out nocopy varchar2,

out_rounding_factor out nocopy varchar2,

out_terms_id out nocopy number,

out_gsa_indicator out nocopy varchar2,

out_currency out nocopy varchar2,

out_freight_terms_code out nocopy varchar2);



PROCEDURE  get_item_information(
            in_inventory_item_id in number
           ,in_org_id in number
,out_item_status out nocopy varchar2

,out_wsh out nocopy varchar2

,out_wsh_name out nocopy varchar2

,out_category out nocopy varchar2

,out_lead_time out nocopy number

,out_cost out nocopy number

,out_primary_uom out nocopy varchar2

,out_user_item_type out nocopy varchar2

,out_make_or_buy out nocopy varchar2

,out_weight_uom out nocopy varchar2

,out_unit_weight out nocopy number

,out_volume_uom out nocopy varchar2

,out_unit_volume out nocopy number

,out_min_order_quantity out nocopy number

,out_max_order_quantity out nocopy number

,out_fixed_order_quantity out nocopy number

,out_customer_order_flag out nocopy varchar2

,out_internal_order_flag out nocopy varchar2

,out_stockable out nocopy varchar2

,out_reservable out nocopy varchar2

,out_returnable out nocopy varchar2

,out_shippable out nocopy varchar2

,out_orderable_on_web out nocopy varchar2

,out_taxable out nocopy varchar2

,out_serviceable out nocopy varchar2

,out_atp_flag out nocopy varchar2

          );

PROCEDURE print_time(in_place in varchar2);

PROCEDURE print_time2;


PROCEDURE Get_list_line_details( in_list_line_id in number
,out_end_date out nocopy date

,out_start_date out nocopy date

,out_list_line_type_Code out nocopy varchar2

,out_modifier_level_code out nocopy varchar2

                           );

PROCEDURE get_global_availability(
                       in_customer_id in number
                      ,in_customer_site_id in number
                      ,in_inventory_item_id in number
                      ,in_org_id            in number
,x_return_status out nocopy varchar2

,x_msg_data out nocopy varchar2

,x_msg_count out nocopy number

,l_source_orgs_table out nocopy source_orgs_table

                                 );


PROCEDURE different_uom(
                        in_org_id in number
                       ,in_ordered_uom in varchar2
                       ,in_pricing_uom in varchar2
,out_conversion_rate out nocopy number

                       );

FUNCTION get_conversion_rate(in_uom_code in varchar2,
                              in_base_uom in varchar2
                             ) RETURN number;


PROCEDURE Call_mrp_and_inventory(
                        in_org_id in number
,out_on_hand_qty out nocopy number

,out_reservable_qty out nocopy number

,out_available_qty out nocopy varchar2

,out_available_date out nocopy date

,out_error_message out nocopy varchar2

,out_qty_uom out nocopy varchar2

                                );

PROCEDURE set_mrp_debug(out_mrp_file out nocopy varchar2);



PROCEDURE copy_fields_to_globals(
                in_inventory_item_id      in number,
                in_qty                    in number,
                in_uom                    in varchar2,
                in_request_date           in date,
                in_customer_id            in number,
                in_item_identifier_type   in varchar2,
                in_agreement_id           in number,
                in_price_list_id          in number,
                in_ship_to_org_id         in number,
                in_invoice_to_org_id      in number,
                in_ship_from_org_id       in number,
                in_pricing_date           in date,
                in_order_type_id          in number,
                in_currency               in varchar2,
                in_pricing_context        in varchar2,
                in_pricing_attribute1     in varchar2,
                in_pricing_attribute2     in varchar2,
                in_pricing_attribute3     in varchar2,
                in_pricing_attribute4     in varchar2,
                in_pricing_attribute5     in varchar2,
                in_pricing_attribute6     in varchar2,
                in_pricing_attribute7     in varchar2,
                in_pricing_attribute8     in varchar2,
                in_pricing_attribute9     in varchar2,
                in_pricing_attribute10    in varchar2,
                in_pricing_attribute11    in varchar2,
                in_pricing_attribute12    in varchar2,
                in_pricing_attribute13    in varchar2,
                in_pricing_attribute14    in varchar2,
                in_pricing_attribute15    in varchar2,
                in_pricing_attribute16    in varchar2,
                in_pricing_attribute17    in varchar2,
                in_pricing_attribute18    in varchar2,
                in_pricing_attribute19    in varchar2,
                in_pricing_attribute20    in varchar2,
                in_pricing_attribute21    in varchar2,
                in_pricing_attribute22    in varchar2,
                in_pricing_attribute23    in varchar2,
                in_pricing_attribute24    in varchar2,
                in_pricing_attribute25    in varchar2,
                in_pricing_attribute26    in varchar2,
                in_pricing_attribute27    in varchar2,
                in_pricing_attribute28    in varchar2,
                in_pricing_attribute29    in varchar2,
                in_pricing_attribute30    in varchar2,
                in_pricing_attribute31    in varchar2,
                in_pricing_attribute32    in varchar2,
                in_pricing_attribute33    in varchar2,
                in_pricing_attribute34    in varchar2,
                in_pricing_attribute35    in varchar2,
                in_pricing_attribute36    in varchar2,
                in_pricing_attribute37    in varchar2,
                in_pricing_attribute38    in varchar2,
                in_pricing_attribute39    in varchar2,
                in_pricing_attribute40    in varchar2,
                in_pricing_attribute41    in varchar2,
                in_pricing_attribute42    in varchar2,
                in_pricing_attribute43    in varchar2,
                in_pricing_attribute44    in varchar2,
                in_pricing_attribute45    in varchar2,
                in_pricing_attribute46    in varchar2,
                in_pricing_attribute47    in varchar2,
                in_pricing_attribute48    in varchar2,
                in_pricing_attribute49    in varchar2,
                in_pricing_attribute50    in varchar2,
                in_pricing_attribute51    in varchar2,
                in_pricing_attribute52    in varchar2,
                in_pricing_attribute53    in varchar2,
                in_pricing_attribute54    in varchar2,
                in_pricing_attribute55    in varchar2,
                in_pricing_attribute56    in varchar2,
                in_pricing_attribute57    in varchar2,
                in_pricing_attribute58    in varchar2,
                in_pricing_attribute59    in varchar2,
                in_pricing_attribute60    in varchar2,
                in_pricing_attribute61    in varchar2,
                in_pricing_attribute62    in varchar2,
                in_pricing_attribute63    in varchar2,
                in_pricing_attribute64    in varchar2,
                in_pricing_attribute65    in varchar2,
                in_pricing_attribute66    in varchar2,
                in_pricing_attribute67    in varchar2,
                in_pricing_attribute68    in varchar2,
                in_pricing_attribute69    in varchar2,
                in_pricing_attribute70    in varchar2,
                in_pricing_attribute71    in varchar2,
                in_pricing_attribute72    in varchar2,
                in_pricing_attribute73    in varchar2,
                in_pricing_attribute74    in varchar2,
                in_pricing_attribute75    in varchar2,
                in_pricing_attribute76    in varchar2,
                in_pricing_attribute77    in varchar2,
                in_pricing_attribute78    in varchar2,
                in_pricing_attribute79    in varchar2,
                in_pricing_attribute80    in varchar2,
                in_pricing_attribute81    in varchar2,
                in_pricing_attribute82    in varchar2,
                in_pricing_attribute83    in varchar2,
                in_pricing_attribute84    in varchar2,
                in_pricing_attribute85    in varchar2,
                in_pricing_attribute86    in varchar2,
                in_pricing_attribute87    in varchar2,
                in_pricing_attribute88    in varchar2,
                in_pricing_attribute89    in varchar2,
                in_pricing_attribute90    in varchar2,
                in_pricing_attribute91    in varchar2,
                in_pricing_attribute92    in varchar2,
                in_pricing_attribute93    in varchar2,
                in_pricing_attribute94    in varchar2,
                in_pricing_attribute95    in varchar2,
                in_pricing_attribute96    in varchar2,
                in_pricing_attribute97    in varchar2,
                in_pricing_attribute98    in varchar2,
                in_pricing_attribute99    in varchar2,
                in_pricing_attribute100   in varchar2
                );

END oe_oe_availability;

/
