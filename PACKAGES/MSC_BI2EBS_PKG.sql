--------------------------------------------------------
--  DDL for Package MSC_BI2EBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_BI2EBS_PKG" AUTHID CURRENT_USER as
/*  $Header: MSCHBBES.pls 120.0 2007/12/21 23:20:54 hulu noship $ */

function  get_ascp_launch_url(p_params in MSC_HUB_ASCP_PARAM_REC) return varchar2;
function  get_dmtr_launch_url(p_params IN MSC_HUB_DMTR_PARAM_REC) return varchar2;


end msc_bi2ebs_pkg;

/
