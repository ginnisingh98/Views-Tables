--------------------------------------------------------
--  DDL for Package PA_ALLOC_EXTNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ALLOC_EXTNS" AUTHID CURRENT_USER AS
/* $Header: PAXALCXS.pls 120.1 2005/08/09 12:10:53 dlanka noship $ */


TYPE ALLOC_SOURCE_REC IS RECORD (
     PROJECT_ID               NUMBER ,
     TASK_ID                  NUMBER ,
     EXCLUDE_FLAG             VARCHAR2(1)
                              ) ;
TYPE ALLOC_SOURCE_TABTYPE IS TABLE OF ALLOC_SOURCE_REC
INDEX BY BINARY_INTEGER ;

TYPE ALLOC_TARGET_REC IS RECORD (
     PROJECT_ID               NUMBER ,
     TASK_ID                  NUMBER ,
     PERCENT                  NUMBER ,
     EXCLUDE_FLAG             VARCHAR2(1)
                              ) ;
TYPE ALLOC_TARGET_TABTYPE IS TABLE OF ALLOC_TARGET_REC
INDEX BY BINARY_INTEGER ;

TYPE ALLOC_OFFSET_REC IS RECORD (
     PROJECT_ID               NUMBER
,    TASK_ID                  NUMBER
,    OFFSET_AMOUNT            NUMBER
                              ) ;

TYPE ALLOC_OFFSET_TABTYPE IS TABLE OF ALLOC_OFFSET_REC
INDEX BY BINARY_INTEGER ;

PROCEDURE source_extn( p_alloc_rule_id  IN NUMBER
                     , x_source_proj_task_tbl OUT NOCOPY ALLOC_SOURCE_TABTYPE);

PROCEDURE offset_extn( p_alloc_rule_id IN NUMBER
                     , p_offset_amount IN NUMBER
                     , x_offset_proj_task_tbl OUT NOCOPY ALLOC_OFFSET_TABTYPE);

PROCEDURE offset_task_extn( p_alloc_rule_id     IN NUMBER
                          , p_offset_project_id IN NUMBER
                          , x_offset_task_id    OUT NOCOPY NUMBER);

PROCEDURE basis_extn( p_alloc_rule_id IN  NUMBER
                    , p_project_id    IN  NUMBER
                    , p_task_id       IN  NUMBER
                    , x_basis_amount  OUT NOCOPY NUMBER);

PROCEDURE target_extn( p_alloc_rule_id  IN NUMBER
                     , x_target_proj_task_tbl OUT NOCOPY ALLOC_TARGET_TABTYPE);

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
                     ) ;

END PA_ALLOC_EXTNS;

 

/
