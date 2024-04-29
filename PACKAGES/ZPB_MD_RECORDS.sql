--------------------------------------------------------
--  DDL for Package ZPB_MD_RECORDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_MD_RECORDS" AUTHID CURRENT_USER AS
/* $Header: zpbmdrecs.pls 120.0.12010.2 2005/12/23 08:19:18 appldev noship $ */
type DIMENSIONS_ENTRY is record
   (
 AwName                                           VARCHAR2(30),
 BusAreaID                                        NUMBER,
 DefaultHier                              VARCHAR2(60),
 DefaultMember                            VARCHAR2(60),
 DimensionId                              NUMBER,
 DimCode                                          VARCHAR2(30),
 DimType                                          VARCHAR2(30),
 EpbId                                            VARCHAR2(30),
 IsCurrencyDim                            VARCHAR2(3),
 IsDataDim                                        VARCHAR2(3),
 IsOwnerDim                                       VARCHAR2(3),
 PersCWMName                              VARCHAR2(60),
 PersTableId                              NUMBER,
 SharCWMName                              VARCHAR2(60),
 SharTableId                              NUMBER,
 AnnotationDim                            VARCHAR2(30),
 CreatedBy                                        NUMBER(15),
 CreationDate                             DATE,
 LastUpdatedBy                            NUMBER(15),
 LastUpdatedDate                          DATE,
 LastUpdatedLogin                         NUMBER(15)
);

type DIMENSIONS_TL_ENTRY is record
(
 DimensionId                             NUMBER,
 Language                                        VARCHAR2(4),
 LongName                                        VARCHAR2(240),
 Name                                            VARCHAR2(240),
 PluralLongName                          VARCHAR2(240),
 PluralName                                      VARCHAR2(240),
 CreatedBy                                       NUMBER(15),
 CreationDate                            DATE,
 LastUpdatedBy                           NUMBER(15),
 LastUpdatedDate                         DATE,
 LastUpdatedLogin                        NUMBER(15)
);

type CUBE_DIMS_ENTRY is record
(
 ColumnId                                        NUMBER,
 CubeId                                          NUMBER,
 DimensionId                             NUMBER,
 RelationId                                      NUMBER,
 CreatedBy                                       NUMBER(15),
 CreationDate                            DATE,
 LastUpdatedBy                           NUMBER(15),
 LastUpdatedDate                         DATE,
 LastUpdatedLogin                        NUMBER(15)
);

type CUBES_ENTRY is record
(
 BusAreaId                                      NUMBER,
 CubeId                                         NUMBER,
 EpbId                                          VARCHAR2(30),
 Name                                           VARCHAR2(60),
 TableId                                        NUMBER,
 Type                                           VARCHAR2(30),
 CreatedBy                                      NUMBER(15),
 CreationDate                           DATE,
 LastUpdatedBy                          NUMBER(15),
 LastUpdatedDate                        DATE,
 LastUpdatedLogin                       NUMBER(15)
);

type MEASURES_ENTRY is record
(
 AwName                                                 VARCHAR2(30),
 ColumnId                                               NUMBER,
 CubeId                                                 NUMBER,
 CurrencyType                                   VARCHAR2(30),
 CurrInstFlag                                   VARCHAR2(3),
 CwmName                                                VARCHAR2(60),
 EpbId                                                  VARCHAR2(30),
 InstanceId                                             NUMBER,
 MeasureId                                              NUMBER,
 TemplateId                                             NUMBER,
 ApproveeId                                             VARCHAR2(240),
 Type                                                   VARCHAR2(64),
 SelectedCur                                    VARCHAR2(30),
 Name                                                   VARCHAR2(255),
 CurrencyRel                                VARCHAR2(30),
 CPRMeasure                                             VARCHAR2(3),
 CreatedBy                                              NUMBER(15),
 CreationDate                                   DATE,
 LastUpdatedBy                                  NUMBER(15),
 LastUpdatedDate                                DATE,
 LastUpdatedLogin                               NUMBER(15)
);

type CUBE_HIER_ENTRY is record
(
 ColumnId                         NUMBER,
 CubeId                           NUMBER,
 HierarchyId          NUMBER,
 RelationId                       NUMBER,
 CreatedBy                        NUMBER(15),
 CreationDate         DATE,
 LastUpdatedBy            NUMBER(15),
 LastUpdatedDate          DATE,
 LastUpdatedLogin         NUMBER(15)
);

type TABLES_ENTRY is record
(
 AwName                           VARCHAR2(30),
 BusAreaId                        NUMBER,
 TableId                          NUMBER,
 TableName                        VARCHAR2(60),
 TableType                        VARCHAR2(30),
 CreatedBy                        NUMBER(15),
 CreationDate             DATE,
 LastUpdatedBy            NUMBER(15),
 LastUpdatedDate          DATE,
 LastUpdatedLogin         NUMBER(15)
);

type COLUMNS_ENTRY is record
(
 ColumnId                         NUMBER,
 AwName                           VARCHAR2(30),
 ColumnName                       VARCHAR2(60),
 ColumnType                       VARCHAR2(30),
 TableId                          NUMBER,
 CreatedBy                        NUMBER(15),
 CreationDate             DATE,
 LastUpdatedBy            NUMBER(15),
 LastUpdatedDate          DATE,
 LastUpdatedLogin         NUMBER(15)
);

type ATTRIBUTES_ENTRY is record
(
 AttributeId                      NUMBER,
 DimensionId                      NUMBER,
 EpbId                                VARCHAR2(30),
 Label                                    VARCHAR2(240),
 RangeDimId                               NUMBER,
 SharCWMName                      VARCHAR2(60),
 Type                                     VARCHAR2(30),
 PersCWMName                      VARCHAR2(60),
 FEMAttrId                                NUMBER,
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type ATTR_TABLE_COL_ENTRY is record
(
 AttributeId                      NUMBER,
 ColumnId                                 NUMBER,
 RelationId                               NUMBER,
 TableId                                  NUMBER,
 CreatedBy                                NUMBER(15),
 CreationDate                 DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type ATTRIBUTES_TL_ENTRY is record
(
 AttributeId                      NUMBER,
 Language                             VARCHAR2(4),
 LongName                                 VARCHAR2(240),
 Name                                     VARCHAR2(240),
 PluralLongName                   VARCHAR2(240),
 PluralName                               VARCHAR2(240),
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type HIERARCHIES_TL_ENTRY is record
(
 HierarchyId                      NUMBER,
 Language                         VARCHAR2(4),
 LongName                                 VARCHAR2(240),
 Name                                     VARCHAR2(240),
 PluralLongName                   VARCHAR2(240),
 PluralName                               VARCHAR2(240),
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type HIERARCHIES_ENTRY is record
(
 DimensionId                     NUMBER,
 EpbId                                   VARCHAR2(30),
 HierarchyId                             NUMBER,
 HierType                                VARCHAR2(30),
 PersCWMName                     VARCHAR2(60),
 PersTableId                     NUMBER,
 SharCWMName                     VARCHAR2(60),
 SharTableId                     NUMBER,
 CreatedBy                               NUMBER(15),
 CreationDate                    DATE,
 LastUpdatedBy                   NUMBER(15),
 LastUpdatedDate                 DATE,
 LastUpdatedLogin                NUMBER(15)
);

type HIER_LEVEL_ENTRY is record
(
 HierId                                   NUMBER,
 LevelId                                  NUMBER,
 LevelOrder                               NUMBER,
 PersColId                                NUMBER,
 RelationId                               NUMBER,
 SharColId                                NUMBER,
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type LEVELS_ENTRY is record
(
 PersCWMName                  VARCHAR2(240),
 DimensionId                      NUMBER,
 EpbId                                    VARCHAR2(30),
 LevelId                                  NUMBER,
 SharCWMName                      VARCHAR2(60),
 PersLevelFlag                    VARCHAR2(3),
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type LEVELS_TL_ENTRY is record
(
 Language                                       VARCHAR2(4),
 LevelId                                        NUMBER,
 LongName                                       VARCHAR2(240),
 Name                                           VARCHAR2(240),
 PluralLongName                         VARCHAR2(240),
 PluralName                                     VARCHAR2(240),
 CreatedBy                                      NUMBER(15),
 CreationDate                           DATE,
 LastUpdatedBy                          NUMBER(15),
 LastUpdatedDate                        DATE,
 LastUpdatedLogin                       NUMBER(15)
);

type MEAS_SCOPE_ENTRY is record
(
 EndDate                                  DATE,
 MeasureId                                NUMBER,
 ScopeId                                  NUMBER,
 StartDate                                DATE,
 UserId                                   NUMBER,
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type HIER_SCOPE_ENTRY is record
(
 EndDate                                  DATE,
 HierarchyId                      NUMBER,
 ScopeId                              NUMBER,
 StartDate                                DATE,
 UserId                           NUMBER,
 PersTableId                      NUMBER,
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type HIER_LEVEL_SCOPE_ENTRY is record
(
 HierId                                   NUMBER,
 LevelId                                  NUMBER,
 ScopeId                                  NUMBER,
 UserId                                   NUMBER,
 PersColId                                NUMBER,
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);

type ATTRIBUTE_SCOPE_ENTRY is record
(
 AttributeId                     NUMBER,
 EndDate                                 DATE,
 ScopeId                             NUMBER,
 StartDate                               DATE,
 UserId                              NUMBER,
 CreatedBy                                NUMBER(15),
 CreationDate                     DATE,
 LastUpdatedBy                    NUMBER(15),
 LastUpdatedDate                  DATE,
 LastUpdatedLogin                 NUMBER(15)
);


end ZPB_MD_RECORDS;


 

/
