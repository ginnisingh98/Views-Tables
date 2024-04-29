--------------------------------------------------------
--  DDL for Package ENG_CANCEL_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CANCEL_ECO" AUTHID CURRENT_USER as
/* $Header: ENGCNCLS.pls 120.0.12010000.1 2008/07/28 06:22:51 appldev ship $ */

Procedure Cancel_Eco (
    org_id		number,
    change_order	varchar2,
    user_id		number,
    login		number
--    comment		varchar2
);

Procedure Cancel_Revised_Item (
    rev_item_seq	number,
    bill_seq_id		number,
    user_id		number,
    login		number,
    change_order	varchar2
--    comment		varchar2
);

Procedure Cancel_Revised_Component (
    comp_seq_id		number,
    user_id		number,
    login		number,
    comment		varchar2
);

Procedure Change_Att_Status (
    p_change_id		number,
    user_id		number,
    login_id		number
);

END ENG_CANCEL_ECO;

/
