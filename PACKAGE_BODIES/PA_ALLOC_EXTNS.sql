--------------------------------------------------------
--  DDL for Package Body PA_ALLOC_EXTNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ALLOC_EXTNS" AS
/* $Header: PAXALCXB.pls 120.2 2005/08/09 16:22:56 dlanka noship $ */

PROCEDURE source_extn(p_alloc_rule_id   IN NUMBER,
            x_source_proj_task_tbl  OUT NOCOPY ALLOC_SOURCE_TABTYPE )
IS
BEGIN
  NULL ;
EXCEPTION
  WHEN OTHERS THEN
	null;
END source_extn;

PROCEDURE offset_extn( p_alloc_rule_id IN NUMBER
                     , p_offset_amount IN NUMBER
                     , x_offset_proj_task_tbl OUT NOCOPY ALLOC_OFFSET_TABTYPE )
IS
BEGIN
null;
EXCEPTION
  WHEN OTHERS THEN
	null;
END offset_extn;

PROCEDURE offset_task_extn( p_alloc_rule_id     IN  NUMBER
                          , p_offset_project_id IN  NUMBER
                          , x_offset_task_id    OUT NOCOPY NUMBER ) IS
BEGIN
  NULL;
EXCEPTION
  WHEN OTHERS THEN
	null;
END offset_task_extn;

PROCEDURE target_extn(p_alloc_rule_id        IN NUMBER ,
                      x_target_proj_task_tbl OUT NOCOPY ALLOC_TARGET_TABTYPE)
IS
BEGIN
  NULL;

EXCEPTION
  WHEN OTHERS THEN
	null;
END target_extn;

PROCEDURE basis_extn(p_alloc_rule_id   IN  NUMBER
                    , p_project_id     IN  NUMBER
                    , p_task_id        IN  NUMBER
                    , x_basis_amount   OUT NOCOPY NUMBER ) IS
BEGIN
  NULL;
EXCEPTION
  WHEN OTHERS THEN
	null;
END basis_extn;

PROCEDURE txn_dff_extn( p_alloc_rule_id    IN NUMBER
                       ,p_run_id           IN NUMBER
                       ,p_txn_type         IN VARCHAR2
                       ,p_project_id       IN VARCHAR2
                       ,P_task_id          IN VARCHAR2
                       ,p_expnd_org        IN VARCHAR2
                       ,p_expnd_type_class IN VARCHAR2
                       ,p_expnd_type       IN VARCHAR2
                       ,x_attribute_category OUT NOCOPY VARCHAR2
                       ,x_attribute1         OUT NOCOPY VARCHAR2
                       ,x_attribute2         OUT NOCOPY VARCHAR2
                       ,x_attribute3         OUT NOCOPY VARCHAR2
                       ,x_attribute4         OUT NOCOPY VARCHAR2
                       ,x_attribute5         OUT NOCOPY VARCHAR2
                       ,x_attribute6         OUT NOCOPY VARCHAR2
                       ,x_attribute7         OUT NOCOPY VARCHAR2
                       ,x_attribute8         OUT NOCOPY VARCHAR2
                       ,x_attribute9         OUT NOCOPY VARCHAR2
                       ,x_attribute10        OUT NOCOPY VARCHAR2
                     ) IS
BEGIN
  NULL;
EXCEPTION
  WHEN OTHERS THEN
	null;
END txn_dff_extn ;
END PA_ALLOC_EXTNS;

/
