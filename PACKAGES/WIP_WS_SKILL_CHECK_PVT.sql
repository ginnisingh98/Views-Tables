--------------------------------------------------------
--  DDL for Package WIP_WS_SKILL_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_SKILL_CHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: wipwsscs.pls 120.0.12010000.3 2009/04/30 12:08:05 pfauzdar noship $ */

G_PREF_ORG_ATTRIBUTE VARCHAR2(30) := 'Org';
G_PREF_CLOCK_ATTRIBUTE VARCHAR2(30) := 'Clock';
G_PREF_MOVE_ATTRIBUTE VARCHAR2(30) := 'Move';
G_PREF_CERTIFY_ATTRIBUTE VARCHAR2(30) := 'Certify';

G_PREF_CLOCK_VALUE NUMBER := 1;
G_PREF_MOVE_VALUE NUMBER := 0;
G_PREF_CERTIFY_VALUE NUMBER := 0;

G_DISABLE_CLOCK_VALIDATION CONSTANT NUMBER :=1;
G_ALLOW_ONLY_SKILL_OPERATORS CONSTANT NUMBER :=2;
G_ALLOW_ALL_OPERATORS CONSTANT NUMBER :=3;

G_DISABLE_MOVE_VALIDATION CONSTANT NUMBER := 0;
G_ENABLE_MOVE_VALIDATION NUMBER := 1;

G_DISABLE_CERTIFICATION_CHECK CONSTANT NUMBER := 0;
G_ENABLE_CERTIFICATION_CHECK CONSTANT NUMBER := 1;

G_SKILL_CHECK_ENABLED CONSTANT NUMBER :=1;

G_SKILL_VALIDATION_SUCCESS   CONSTANT NUMBER :=1;
G_COMPETENCE_CHECK_FAIL      CONSTANT NUMBER :=2;
G_CERTIFY_CHECK_FAIL         CONSTANT NUMBER :=3;
G_QUALIFY_CHECK_FAIL         CONSTANT NUMBER :=4;
G_INV_SKILL_CHECK_EMP        CONSTANT NUMBER :=5;
G_SKILL_VALIDATION_EXCEPTION CONSTANT NUMBER :=6;
G_NO_SKILL_EMP_CLOCKIN       CONSTANT NUMBER :=7;

G_WIP_ENTITY_NAME VARCHAR2(240);
G_EMPLOYEE VARCHAR2(240);

function validate_skill_for_clock_in(p_wip_entity_id   in number,
                                     p_op_seq_num      in number,
                                     p_emp_id          in number)
return number;

procedure validate_skill_for_move_txn(p_wip_entity_id   in number,
                                      p_organization_id in number,
                                      p_from_op         in number,
                                      p_to_op           in number,
                                      p_from_step       in number,
                                      p_to_step         in number,
                                      p_emp_id          in number,
                                      l_validate_skill out nocopy number,
                                      l_move_pref      out nocopy varchar2,
                                      l_certify_pref   out nocopy varchar2,
                                      l_err_msg        out nocopy varchar2);

procedure validate_skill_for_exp_move(p_wip_entity_id   in number,
                                      p_organization_id in number,
                                      p_op_seq_num      in number,
                                      p_emp_id          in number,
                                      l_validate_skill out nocopy number,
                                      l_err_msg        out nocopy varchar2);

END WIP_WS_SKILL_CHECK_PVT;

/
