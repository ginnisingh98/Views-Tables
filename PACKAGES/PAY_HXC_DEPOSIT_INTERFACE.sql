--------------------------------------------------------
--  DDL for Package PAY_HXC_DEPOSIT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HXC_DEPOSIT_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: pyhxcdpi.pkh 120.0.12010000.2 2008/08/06 07:23:44 ubhat ship $ */

TYPE r_full_name is RECORD(
person_id NUMBER(9),
full_name VARCHAR2(240),
effective_start_date date,
effective_end_date date
);
TYPE t_full_name is table of r_full_name index by binary_integer;
g_full_name_ct t_full_name;

TYPE r_asg is RECORD(
effective_start_date date,
effective_end_date date,
assignment_id number(9),
business_group_id number(9),
cost_allocation_structure varchar2(150)
);
TYPE t_asg is table of r_asg index by binary_integer;
g_asg_ct t_asg;

user_language varchar2(4);

TYPE r_ele_type is RECORD(
element_name VARCHAR2(80),
effective_start_date date,
effective_end_date date
);

TYPE t_ele_type is TABLE OF r_ele_type INDEX BY BINARY_INTEGER;
g_ele_type_ct t_ele_type;

TYPE r_iv_map is RECORD(
effective_start_date date,
effective_end_date date,
start_index BINARY_INTEGER,
stop_index BINARY_INTEGER
);
TYPE t_iv_map IS TABLE OF r_iv_map INDEX BY BINARY_INTEGER;
g_iv_map_ct t_iv_map;


TYPE r_iv_lk_map IS RECORD(
iv_name pay_input_values_f.name%TYPE,
lcode HR_LOOKUPS.lookup_code%TYPE
);
TYPE t_iv_lk_map IS TABLE OF r_iv_lk_map INDEX BY BINARY_INTEGER;
g_iv_lk_map_ct t_iv_lk_map;

TYPE r_ivn IS RECORD(
element_type_id NUMBER(9),
field_name VARCHAR2(80),
ipv_name PAY_INPUT_VALUES_F.NAME%TYPE
);
TYPE t_ivn is TABLE OF r_ivn INDEX BY BINARY_INTEGER;
g_ivn_ct t_ivn;

TYPE r_link is RECORD(
assignment_id NUMBER(9),
element_type_id NUMBER(9),
effective_date date,
element_link_id NUMBER(9)
);
TYPE t_link IS TABLE OF r_link INDEX BY BINARY_INTEGER;
g_link_ct t_link;


TYPE r_iv_mapping IS RECORD (
        iv_name    pay_input_values_f.name%TYPE
,       iv_id      pay_input_values_f.input_value_id%TYPE
,       iv_seq     pay_input_values_f.display_sequence%TYPE
,       iv_uom     pay_input_values_f.uom%TYPE );
TYPE t_iv_mapping IS TABLE OF r_iv_mapping INDEX BY BINARY_INTEGER;
g_iv_mapping_ct     t_iv_mapping;


-- TYPE r_canonical_iv_id IS RECORD ( flag VARCHAR2(1) );
-- TYPE t_canonical_iv_id IS TABLE OF r_canonical_iv_id INDEX BY BINARY_INTEGER;
TYPE t_canonical_iv_id IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

g_canonical_iv_id_tab t_canonical_iv_id;


FUNCTION pay_retrieval_process RETURN VARCHAR2;

FUNCTION hr_retrieval_process RETURN VARCHAR2;

PROCEDURE pay_validate_process
            (p_operation            IN     VARCHAR2);

PROCEDURE pay_validate_timecard
   (p_operation       IN     VARCHAR2
   ,p_time_building_blocks IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info
   ,p_time_attributes IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info
   ,p_messages        IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE);

PROCEDURE pay_update_process
            (p_operation            IN     VARCHAR2);

PROCEDURE pay_update_timecard
           (p_attributes     IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info,
            p_blocks         in    hxc_self_service_time_deposit.timecard_info
	   );
END pay_hxc_deposit_interface;

/
