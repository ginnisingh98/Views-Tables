--------------------------------------------------------
--  DDL for Package Body CS_SR_COMP_SUBCOMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_COMP_SUBCOMP_PKG" AS
/* $Header: csxamgrb.pls 120.1 2005/06/13 13:56:02 appldev  $ */

PROCEDURE SR_DYNAMIC_ASSIGN
( l_sr_rec          IN OUT NOCOPY JTF_ASSIGN_PUB.JTF_SERV_REQ_REC_TYPE
, l_component_id    IN NUMBER
, l_subcomponent_id in number ) IS
BEGIN
  CS_SR_COMP_SUBCOMP_PKG.ll_sr_rec := null ;
  CS_SR_COMP_SUBCOMP_PKG.ll_sr_rec := l_sr_rec ;

  EXECUTE IMMEDIATE
  'BEGIN
     CS_SR_COMP_SUBCOMP_PKG.ll_sr_rec.item_component     := :1;
     CS_SR_COMP_SUBCOMP_PKG.ll_sr_rec.item_subcomponent  := :2;
   END;'
   USING l_component_id, l_subcomponent_id ;

   l_sr_rec                         := CS_SR_COMP_SUBCOMP_PKG.ll_sr_rec ;
   CS_SR_COMP_SUBCOMP_PKG.ll_sr_rec := null ;

END SR_DYNAMIC_ASSIGN ;

PROCEDURE TASK_DYNAMIC_ASSIGN
( l_task_rec IN OUT NOCOPY JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE
, l_component_id in number
, l_subcomponent_id in number ) IS

BEGIN
  CS_SR_COMP_SUBCOMP_PKG.ll_sr_task_rec := null ;
  CS_SR_COMP_SUBCOMP_PKG.ll_sr_task_rec := l_task_rec ;

  EXECUTE IMMEDIATE
  'BEGIN
     CS_SR_COMP_SUBCOMP_PKG.ll_sr_task_rec.item_component     := :1;
     CS_SR_COMP_SUBCOMP_PKG.ll_sr_task_rec.item_subcomponent  := :2;
   END;'
   USING l_component_id, l_subcomponent_id ;

   l_task_rec                            := CS_SR_COMP_SUBCOMP_PKG.ll_sr_task_rec ;
   CS_SR_COMP_SUBCOMP_PKG.ll_sr_task_rec := null ;

END TASK_DYNAMIC_ASSIGN ;

END CS_SR_COMP_SUBCOMP_PKG ;

/
