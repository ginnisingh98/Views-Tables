--------------------------------------------------------
--  DDL for Package PAY_PAYWSLEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYWSLEE_PKG" AUTHID CURRENT_USER as
/* $Header: paywslee.pkh 115.3 2002/12/05 16:53:15 rthirlby ship $ */
--
--type SevTabType IS TABLE OF PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE%TYPE
type SevTabType IS TABLE OF VARCHAR2(80)
     index by binary_integer;
type UomTabType IS TABLE OF PAY_INPUT_VALUES_F.UOM%TYPE
     index by binary_integer;
type IvnTabType IS TABLE OF PAY_INPUT_VALUES_F.NAME%TYPE
     index by binary_integer;
--
procedure get_input_value_names (
--
p_element_type_id	in	       number,
p_name1			in out	nocopy varchar2,
p_name2			in out	nocopy varchar2,
p_name3			in out	nocopy varchar2,
p_name4			in out	nocopy varchar2,
p_name5			in out	nocopy varchar2,
p_name6			in out	nocopy varchar2,
p_name7			in out	nocopy varchar2,
p_name8			in out	nocopy varchar2,
p_name9			in out	nocopy varchar2,
p_name10		in out	nocopy varchar2,
p_name11		in out	nocopy varchar2,
p_name12		in out	nocopy varchar2,
p_name13		in out	nocopy varchar2,
p_name14		in out	nocopy varchar2,
p_name15		in out	nocopy varchar2);
--
procedure get_input_value_names (
p_rows                  in out  nocopy number,
p_element_type_id       in             number,
p_ivn_tab               in out  nocopy IvnTabType);
--
procedure get_entry_details (
--
p_element_entry_id	in	       number,
p_element_link_id	in	       number,
p_assignment_id		in	       number,
p_effective_end_date	in	       date,
p_full_name		in out	nocopy varchar2,
p_assignment_number	in out	nocopy varchar2,
p_screen_entry_value1	in out	nocopy varchar2,
p_screen_entry_value2	in out	nocopy varchar2,
p_screen_entry_value3	in out	nocopy varchar2,
p_screen_entry_value4	in out	nocopy varchar2,
p_screen_entry_value5	in out	nocopy varchar2,
p_screen_entry_value6	in out	nocopy varchar2,
p_screen_entry_value7	in out	nocopy varchar2,
p_screen_entry_value8	in out	nocopy varchar2,
p_screen_entry_value9	in out	nocopy varchar2,
p_screen_entry_value10	in out	nocopy varchar2,
p_screen_entry_value11	in out	nocopy varchar2,
p_screen_entry_value12	in out	nocopy varchar2,
p_screen_entry_value13	in out	nocopy varchar2,
p_screen_entry_value14	in out	nocopy varchar2,
p_screen_entry_value15	in out	nocopy varchar2,
p_uom1			in out	nocopy varchar2,
p_uom2			in out	nocopy varchar2,
p_uom3			in out	nocopy varchar2,
p_uom4			in out	nocopy varchar2,
p_uom5			in out	nocopy varchar2,
p_uom6			in out	nocopy varchar2,
p_uom7			in out	nocopy varchar2,
p_uom8			in out	nocopy varchar2,
p_uom9			in out	nocopy varchar2,
p_uom10			in out	nocopy varchar2,
p_uom11			in out	nocopy varchar2,
p_uom12			in out	nocopy varchar2,
p_uom13			in out	nocopy varchar2,
p_uom14			in out	nocopy varchar2,
p_uom15			in out	nocopy varchar2);
--
procedure get_entry_details (
--
p_rows                  in out  nocopy number,
p_element_entry_id      in             number,
p_element_link_id       in             number,
p_assignment_id         in             number,
p_effective_end_date    in             date,
p_full_name             in out  nocopy varchar2,
p_assignment_number     in out  nocopy varchar2,
p_entry_value_tab       in out  nocopy SevTabType,
p_uom_tab               in out  nocopy UomTabType);
--
end PAY_PAYWSLEE_PKG;

 

/
