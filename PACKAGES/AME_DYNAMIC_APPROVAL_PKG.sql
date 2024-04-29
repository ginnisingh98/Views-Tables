--------------------------------------------------------
--  DDL for Package AME_DYNAMIC_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_DYNAMIC_APPROVAL_PKG" AUTHID CURRENT_USER as
/* $Header: amedapkg.pkh 120.0 2005/07/26 05:55:27 mbocutt noship $ */

PROCEDURE get_ame_apprs_and_ins_list(
           p_application_id in integer,
           p_transaction_type in varchar2,
           p_transaction_id in varchar2,
           p_apprs_view_type in varchar2 default 'Active',
           p_coa_insertions_flag in varchar2 default 'N',
           p_ame_approvers_list  OUT NOCOPY ame_approver_record2_table_ss,
           p_ame_order_type_list OUT NOCOPY ame_insertion_record2_table_ss,
           p_all_approvers_count out  NOCOPY varchar2,
           p_warning_msg_name    OUT NOCOPY varchar2,
           p_error_msg_text      OUT NOCOPY varchar2
);

PROCEDURE insert_ame_approver(
           p_application_id in number,
           p_transaction_type in varchar2,
           p_transaction_id in varchar2,
           p_approverIn in ame_approver_record2_table_ss,
           p_positionIn in number,
           p_insertionIn in ame_insertion_record2_table_ss,
           p_warning_msg_name     OUT NOCOPY varchar2,
           p_error_msg_text       OUT NOCOPY varchar2

    );

PROCEDURE delete_ame_approver(
           p_application_id in number,
           p_transaction_type in varchar2,
           p_transaction_id in varchar2,
           p_approverIn in ame_approver_record2_table_ss,
           p_warning_msg_name     OUT NOCOPY varchar2,
           p_error_msg_text       OUT NOCOPY varchar2

    );


end ame_dynamic_approval_pkg;

 

/
