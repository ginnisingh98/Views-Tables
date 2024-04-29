--------------------------------------------------------
--  DDL for Package QP_QUALIFICATION_IND_UPG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QUALIFICATION_IND_UPG_UTIL" AUTHID CURRENT_USER as
/* $Header: QPXUQUAS.pls 120.0 2005/06/02 00:54:45 appldev noship $ */

procedure initialize_qualification_ind(
p_batchsize IN NUMBER := 5000,
l_worker    IN NUMBER := 1);

procedure reinit_qualification_ind(
p_batchsize IN NUMBER := 5000,
l_worker    IN NUMBER := 1);

procedure set_qualification_ind(
p_batchsize IN NUMBER := 5000,
l_worker IN NUMBER := 1);

PROCEDURE  create_parallel_slabs(
l_workers IN NUMBER := 5,
l_type    IN VARCHAR2 := 'QUA');

PROCEDURE  create_parallel_count_slabs(
l_workers IN NUMBER := 5,
l_type    IN VARCHAR2 := 'QIN');

end qp_qualification_ind_upg_util;

 

/
