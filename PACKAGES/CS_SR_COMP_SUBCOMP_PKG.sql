--------------------------------------------------------
--  DDL for Package CS_SR_COMP_SUBCOMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_COMP_SUBCOMP_PKG" AUTHID CURRENT_USER as
/* $Header: csxamgrs.pls 120.1 2005/06/13 13:53:34 appldev  $ */

ll_sr_rec                 JTF_ASSIGN_PUB.JTF_Serv_req_rec_type;
ll_sr_task_rec            JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE ;

PROCEDURE SR_Dynamic_Assign
( l_sr_rec IN OUT NOCOPY JTF_ASSIGN_PUB.JTF_SERV_REQ_REC_TYPE
, l_component_id in number
, l_subcomponent_id in number
) ;

PROCEDURE Task_Dynamic_Assign
( l_task_rec IN OUT NOCOPY JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE
, l_component_id in number
, l_subcomponent_id in number
) ;

END CS_SR_COMP_SUBCOMP_PKG;
 

/
