--------------------------------------------------------
--  DDL for Package PQH_ATTRIBUTE_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATTRIBUTE_RANGES_PKG" AUTHID CURRENT_USER as
/* $Header: pqrngchk.pkh 115.12 2002/12/12 22:47:38 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Record
-- ----------------------------------------------------------------------------
--
     type att_rec is record (attribute_name pqh_attributes.attribute_name%type,
                             attribute_id   pqh_txn_category_attributes.attribute_id%type,
                             column_type    pqh_attributes.column_type%type,
                             value_style_cd pqh_txn_category_attributes.value_style_cd%type,
                             value_set_id   pqh_txn_category_attributes.value_set_id%type);


     type att_tab is table of att_rec index by binary_integer;

     type att_ranges_rec is record(
                      attribute_range_id pqh_attribute_ranges.attribute_range_id%type,
                        attribute_id     pqh_attribute_ranges.attribute_id%type,
                        from_char        pqh_attribute_ranges.from_char%type,
                        to_char          pqh_attribute_ranges.to_char%type,
                        from_date        pqh_attribute_ranges.from_date%type,
                        to_date          pqh_attribute_ranges.to_date%type,
                        from_number      pqh_attribute_ranges.from_number%type,
                        to_number        pqh_attribute_ranges.to_number%type,
                        ovn              pqh_attribute_ranges.object_version_number%type,
                        operation        varchar2(1));


     type att_ranges is table of att_ranges_rec index by binary_integer;
     --
     -- attribute ranges passed from form
     --
     type rule_attr_rec is record
                       (attribute_id     pqh_attributes.attribute_id%type,
                        datatype         pqh_attributes.column_type%type,
                        from_char        pqh_attribute_ranges.from_char%type,
                        to_char          pqh_attribute_ranges.to_char%type,
                        from_number      pqh_attribute_ranges.from_number%type,
                        to_number        pqh_attribute_ranges.to_number%type,
                        from_date        pqh_attribute_ranges.from_date%type,
                        to_date          pqh_attribute_ranges.to_date%type);

     type rule_attr_tab is table of rule_attr_rec index by binary_integer;
     --
     -- used to fetch database values for validating ranges
     --
     type other_ranges_rec is record
                  (routing_category_id   pqh_attribute_ranges.routing_category_id%type,
                        range_name       pqh_attribute_ranges.range_name%type,
                        attribute_id     pqh_attribute_ranges.attribute_id%type,
                        from_char        pqh_attribute_ranges.from_char%type,
                        to_char          pqh_attribute_ranges.to_char%type,
                        from_number      pqh_attribute_ranges.from_number%type,
                        to_number        pqh_attribute_ranges.to_number%type,
                        from_date        pqh_attribute_ranges.from_date%type,
                        to_date          pqh_attribute_ranges.to_date%type);

     type other_ranges_tab is table of other_ranges_rec index by binary_integer;
--
-- fetch attributes for the entered transaction category
--
procedure fetch_attributes(p_transaction_category_id in     number,
                           p_att_tab                 in out nocopy att_tab,
                           no_attr                   out nocopy    number,
                           primary_flag              in     varchar2);
--
-- fetch all attribute ranges
--
PROCEDURE fetch_ranges(p_routing_category_id in     number,
                       p_range_name          in     varchar2,
                       p_att_ranges_tab      in out nocopy att_ranges,
                       p_no_attributes       in     number,
                       p_primary_flag        in varchar2);

--
-- Business Rule Validations
--
PROCEDURE chk_routing_range_overlap
                 (tab1                      in rule_attr_tab,
                  tab2                      in rule_attr_tab,
                  p_routing_type            in varchar2,
                  p_transaction_category_id in number,
                  p_attribute_range_id_list in varchar2,
                  p_no_attributes           in number,
                  p_error_code             out nocopy number,
                  p_error_routing_category out nocopy varchar2,
                  p_error_range_name       out nocopy varchar2);
--
FUNCTION chk_enable_routing_category(p_routing_category_id in number,
                                      p_transaction_category_id in number,
                                      p_overlap_range_name     out nocopy varchar2,
                                      p_error_routing_category out nocopy varchar2,
                                      p_error_range_name       out nocopy varchar2
                                      ) RETURN number;
--
Procedure chk_rout_overlap_on_freeze(p_transaction_category_id in number
                                    );
--
FUNCTION chk_member_range_overlap
                (tab1                      in rule_attr_tab,
                 tab2                      in rule_attr_tab,
                 p_transaction_category_id in number,
                 p_routing_category_id     in number,
                 p_range_name              in varchar2,
                 p_routing_type            in varchar2,
                 p_member_id               in number,
                 p_attribute_range_id_list in varchar2,
                 p_no_attributes           in number,
                 p_error_range             out nocopy varchar2) RETURN number;
--
PROCEDURE chk_mem_overlap_on_freeze( p_transaction_category_id in number
                                  ) ;
PROCEDURE get_member_name(p_member_id    in  number,
                          p_routing_type in  varchar2,
                          p_member_name out nocopy  varchar2);
--
-- Wrapper DML's
--
PROCEDURE on_insert_attribute_ranges(
                                   p_routing_category_id     IN     number,
                                   p_range_name              IN     varchar2,
                                   p_primary_flag            IN     varchar2,
                                   p_routing_list_member_id  IN     number,
                                   p_position_id             IN     number,
                                   p_assignment_id           IN     number,
                                   p_approver_flag           IN     varchar2,
                                   p_enable_flag           IN     varchar2,
                                   ins_attr_ranges_table     IN OUT NOCOPY att_ranges,
                                   p_no_attributes           IN     number);

procedure insert_update_delete_ranges(
                                   p_routing_category_id    in       number,
                                   p_range_name             in       varchar2,
                                   p_primary_flag           in       varchar2,
                                   p_routing_list_member_id in       number,
                                   p_position_id            in       number,
                                   p_assignment_id          in       number,
                                   p_approver_flag          in       varchar2,
                                   p_enable_flag           IN     varchar2,
                                   p_attr_ranges_table      in out nocopy   att_ranges,
                                   p_no_attributes          in       number);

procedure on_delete_attribute_ranges(p_validate            in       boolean,
                                     del_attr_ranges_table in out nocopy   att_ranges,
                                     p_no_attributes       in       number);
--
-- Procedure to raise error when a list / member identifier with
-- child records in pqh_attribute_ranges is unmarked
--
Procedure Delete_attribute_ranges(p_attribute_id            IN number,
                                  p_delete_attr_ranges_flag IN varchar2,
                                  p_primary_flag            IN varchar2);

end;

 

/
