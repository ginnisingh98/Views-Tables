--------------------------------------------------------
--  DDL for Package INV_ATTRIBUTE_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ATTRIBUTE_CONTROL_PVT" AUTHID CURRENT_USER as
/* $Header: INVATTCS.pls 120.0.12010000.2 2008/07/29 12:51:59 ptkumar ship $ */
function get_attribute_control(x_source_item varchar2) return number;

function check_pending_adjustments(p_org_id in number,
                           p_item_id in number,
                           p_source_item varchar2) return boolean;

function reservable_uncheck (p_org_id in number,
                             p_item_id in number) return boolean;

function reservable_check (p_org_id in number,
                           p_item_id in number) return boolean;

function transactable_check(p_org_id in number,
                            p_item_id in number) return boolean;

function transactable_uncheck(p_org_id in number,
                              p_item_id in number) return boolean;

function check_pending_interface(p_org_id in number,
                                 p_item_id in number,
                                 p_source_item varchar2) return boolean;

function serial_check(p_org_id in number,
                      p_item_id in number) return boolean;

function ato_uncheck(p_org_id in number,
                     p_item_id in number) return boolean;

function shippable_check(p_org_id in number,
                         p_item_id in number) return boolean;
end;

/
