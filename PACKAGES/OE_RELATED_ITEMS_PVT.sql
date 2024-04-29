--------------------------------------------------------
--  DDL for Package OE_RELATED_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RELATED_ITEMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXFRELS.pls 120.0 2005/06/01 01:49:51 appldev noship $ */

PROCEDURE get_upgrade_item_details(l_inv_item_id in number,
				   out_inv_item_name out nocopy varchar2,
				   out_inv_desc out nocopy varchar2,
				   out_inv_item_type out nocopy varchar2
				   );

   PROCEDURE  defaulting(
			 p_org_id in varchar2
			 ,p_cust_account_id in number
			 ,p_related_item_id in number
			 ,p_ship_to_org_id in number
			 ,p_line_set_id in number
			 ,p_ship_set_id in number
			 ,p_line_type_id in number
			 ,p_deliver_to_org_id in number
			 ,p_accounting_rule_id in number
			 ,p_accounting_rule_duration in number
			 ,p_actual_arrival_date in date
			 ,p_actual_shipment_date in date
			 ,p_cancelled_flag in varchar2
			 ,p_fob_point_code in varchar2
			 ,p_invoicing_rule_id in number
			 ,p_item_type_code in varchar2
			 ,p_line_category_code in varchar2
			 ,p_open_flag in varchar2
			 ,p_promise_date in date
			 ,p_salesrep_id in number
			 ,p_schedule_ship_date in date
			 ,p_schedule_arrival_date in date
			 ,p_customer_shipment_number in number
			 ,p_agreement_id in number
			 ,p_header_id in number
			 ,p_invoice_to_org_id in number
			 ,p_price_list_id in number
			 ,p_request_date in date
			 ,p_arrival_set_id in number
			 ,x_wsh_id  out nocopy number
			 ,x_uom  out nocopy varchar2
			 );

Procedure Call_MRP_ATP(
               p_global_orgs       in varchar2,
               p_ship_from_org_id  in number,
	       p_related_item_id   in number,
	       p_related_uom       in VARCHAR2,
	       p_request_date	    in DATE,
	       p_ordered_qty	    in NUMBER,
	       p_cust_account_id   in NUMBER,
               p_ship_to_org_id    in NUMBER,
               x_available_qty    out NOCOPY /* file.sql.39 change */ varchar2,
               x_ship_from_org_id out NOCOPY /* file.sql.39 change */ number,
               x_available_date   out NOCOPY /* file.sql.39 change */ date,
               x_qty_uom          out NOCOPY /* file.sql.39 change */ varchar2,
               x_out_message        out NOCOPY /* file.sql.39 change */ varchar2,
               x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
               x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER,
               x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	       x_error_message      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      );

Procedure Check_Results_from_rec (
           p_global_orgs    in varchar2
          ,p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
          ,x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
          ,x_msg_count       OUT NOCOPY /* file.sql.39 change */ NUMBER
          ,x_msg_data        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
          ,x_error_message   out NOCOPY /* file.sql.39 change */ varchar2
                                  );

Procedure Initialize_mrp_record(
          p_x_atp_rec IN  OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
         ,l_count     IN  NUMBER);


PROCEDURE get_ship_from_org(in_org_id in number,
                            out_code out NOCOPY /* file.sql.39 change */ varchar2,
                            out_name out NOCOPY /* file.sql.39 change */ varchar2
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
             );


PROCEDURE set_pricing_control_record (
             l_Control_Rec  in out nocopy QP_PREQ_GRP.CONTROL_RECORD_TYPE
            ,in_pricing_event in varchar2);

PROCEDURE build_context_for_line(
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
        ,p_pricing_contexts_Tbl in out nocopy QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
        ,p_qualifier_contexts_Tbl in out nocopy QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
                             );

PROCEDURE  Append_attributes(
           p_header_id number default null
          ,p_Line_id number default null
          ,p_line_index number
          ,px_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
          ,px_Req_qual_tbl in out nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
           );

PROCEDURE build_context_for_header(
             p_req_line_tbl_count in number,
             p_price_request_code in varchar2,
             p_item_type_code in varchar2,
             p_Req_line_attr_tbl in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
             p_Req_qual_tbl in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
            );

PROCEDURE price_item(
out_req_line_tbl               in out NOCOPY /* file.sql.39 change */ QP_PREQ_GRP.LINE_TBL_TYPE,
out_Req_line_attr_tbl          in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
out_Req_LINE_DETAIL_attr_tbl   in out nocopy  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
out_Req_LINE_DETAIL_tbl        in out nocopy QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
out_Req_related_lines_tbl      in out nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
out_Req_qual_tbl               in out nocopy QP_PREQ_GRP.QUAL_TBL_TYPE,
out_Req_LINE_DETAIL_qual_tbl   in out nocopy QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
out_child_detail_type          out NOCOPY /* file.sql.39 change */ varchar2,
                in_related_item_id      in number,
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
                in_pricing_attribute100   in varchar2,
                in_header_id              in NUMBER
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
                l_return_status        out NOCOPY /* file.sql.39 change */ varchar2,
                l_msg_count out NOCOPY /* file.sql.39 change */ number,
                l_msg_data  out NOCOPY /* file.sql.39 change */ varchar2
                );

Function Get_Rounding_factor(p_list_header_id number) return number;

PROCEDURE get_Price_List_info(
                          p_price_list_id IN  NUMBER,
                          out_name  out NOCOPY /* file.sql.39 change */ varchar2,
                          out_end_date out NOCOPY /* file.sql.39 change */ date,
                          out_start_date out NOCOPY /* file.sql.39 change */ date,
                          out_automatic_flag out NOCOPY /* file.sql.39 change */ varchar2,
                          out_rounding_factor out NOCOPY /* file.sql.39 change */ varchar2,
                          out_terms_id out NOCOPY /* file.sql.39 change */ number,
                          out_gsa_indicator out NOCOPY /* file.sql.39 change */ varchar2,
                          out_currency out NOCOPY /* file.sql.39 change */ varchar2,
                          out_freight_terms_code out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE different_uom(
                        in_org_id in number
                       ,in_ordered_uom in varchar2
                       ,in_pricing_uom in varchar2
                       ,out_conversion_rate out NOCOPY /* file.sql.39 change */ number
                       );

FUNCTION get_conversion_rate(in_uom_code in varchar2,
                              in_base_uom in varchar2
                             ) RETURN number;

PROCEDURE print_time(in_place in varchar2);

PROCEDURE print_time2;
END Oe_Related_Items_Pvt;


 

/
